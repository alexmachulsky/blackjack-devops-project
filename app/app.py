from flask import Flask, render_template, redirect, url_for, session, jsonify, request
import random
import os
from pymongo import MongoClient, errors
import logging
from pythonjsonlogger import jsonlogger
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
app.secret_key = 'replace-this-with-a-secret-key'
metrics = PrometheusMetrics(app)

SUITS = ["♠️", "♥️", "♦️", "♣️"]

# --- Logging Setup ---
logger = logging.getLogger("blackjack")
logger.setLevel(logging.INFO)
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter('%(asctime)s %(levelname)s %(name)s %(message)s')
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)

# --- MongoDB Configuration ---
MONGO_URI = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/blackjackdb')
MONGO_DB = os.environ.get('MONGO_DB', 'blackjackdb')
MONGO_COLL = os.environ.get('MONGO_COLL', 'userstats')

def get_db():
    """Return the MongoDB collection or None if not available."""
    try:
        client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=3000)
        db = client[MONGO_DB]
        coll = db[MONGO_COLL]
        client.admin.command('ping')
        return coll
    except errors.PyMongoError as e:
        logger.error("Could not connect to MongoDB", extra={"error": str(e)})
        return None

def get_stats(user='default'):
    coll = get_db()
    if coll is None:
        return {'win': 0, 'loss': 0, 'draw': 0}
    doc = coll.find_one({'user': user})
    if doc and 'stats' in doc:
        return doc['stats']
    return {'win': 0, 'loss': 0, 'draw': 0}

def save_stats(stats, user='default'):
    coll = get_db()
    if coll is None:
        return
    coll.update_one({'user': user}, {'$set': {'stats': stats}}, upsert=True)

def update_stats(outcome):
    stats = get_stats('default')
    if "win" in outcome:
        stats['win'] += 1
    elif "lose" in outcome:
        stats['loss'] += 1
    else:
        stats['draw'] += 1
    save_stats(stats, 'default')
    session['stats'] = stats

def deal_card():
    value = random.choice([2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11])
    suit = random.choice(SUITS)
    return (value, suit)

def calculate_score(cards):
    values = [card[0] for card in cards]
    score = sum(values)
    aces = values.count(11)
    while score > 21 and aces:
        score -= 10
        aces -= 1
    return score

def format_hand(cards):
    def face(val, idx):
        if val == 11:
            return 'A'
        elif val == 10:
            return "10"
        else:
            return str(val)
    return [f"{face(card[0], idx)}{card[1]}" for idx, card in enumerate(cards)]

def get_outcome(player_score, dealer_score):
    if player_score > 21:
        return "You lose!"
    elif dealer_score > 21 or player_score > dealer_score:
        return "You win!"
    elif player_score == dealer_score:
        return "It's a draw!"
    else:
        return "You lose!"

@app.route('/')
def index():
    def ensure_tuple(card):
        if isinstance(card, tuple):
            return card
        else:
            return (card, random.choice(SUITS))

    if 'player' not in session or 'dealer' not in session:
        session['player'] = [deal_card(), deal_card()]
        session['dealer'] = [deal_card(), deal_card()]
        logger.info("New game started", extra={"event": "new_game"})
    else:
        session['player'] = [ensure_tuple(card) for card in session['player']]
        session['dealer'] = [ensure_tuple(card) for card in session['dealer']]

    player = session['player']
    dealer = session['dealer']
    return render_template(
        'game.html',
        player=format_hand(player),
        player_total=calculate_score(player),
        dealer=[format_hand([dealer[0]])[0], '?'],
        stats=session.get('stats', get_stats('default'))
    )

@app.route('/hit')
def hit():
    player = session.get('player', [])
    player.append(deal_card())
    session['player'] = player
    logger.info("Player hits", extra={"event": "hit", "player_total": calculate_score(player)})
    if calculate_score(player) > 21:
        logger.info("Player busts", extra={"event": "bust", "player_total": calculate_score(player)})
        return redirect(url_for('result'))
    dealer = session.get('dealer', [])
    return render_template(
        'game.html',
        player=format_hand(player),
        player_total=calculate_score(player),
        dealer=[format_hand([dealer[0]])[0], '?'],
        stats=session.get('stats', get_stats('default'))
    )

@app.route('/stand')
def stand():
    dealer = session.get('dealer', [])
    while calculate_score(dealer) < 17:
        dealer.append(deal_card())
    session['dealer'] = dealer
    logger.info("Player stands", extra={"event": "stand", "dealer_total": calculate_score(dealer)})
    return redirect(url_for('result'))

@app.route('/result')
def result():
    player = session.get('player', [])
    dealer = session.get('dealer', [])
    player_score = calculate_score(player)
    dealer_score = calculate_score(dealer)
    outcome = get_outcome(player_score, dealer_score)
    try:
        update_stats(outcome)
    except Exception as e:
        logger.error("Failed to update stats", extra={"error": str(e)})
        # fallback: session-only
        if 'stats' not in session:
            session['stats'] = {'win': 0, 'loss': 0, 'draw': 0}
        if "win" in outcome:
            session['stats']['win'] += 1
        elif "lose" in outcome:
            session['stats']['loss'] += 1
        else:
            session['stats']['draw'] += 1

    logger.info("Game result", extra={
        "event": "game_result",
        "player_total": player_score,
        "dealer_total": dealer_score,
        "outcome": outcome,
        "stats": session.get('stats', get_stats('default'))
    })

    result_data = {
        'player': format_hand(player),
        'dealer': format_hand(dealer),
        'player_total': player_score,
        'dealer_total': dealer_score,
        'outcome': outcome,
        'stats': session.get('stats', get_stats('default'))
    }
    session.pop('player', None)
    session.pop('dealer', None)
    return render_template('result.html', **result_data)

@app.route('/reset')
def reset():
    session.pop('player', None)
    session.pop('dealer', None)
    logger.info("Game reset", extra={"event": "reset"})
    return redirect(url_for('index'))

@app.route('/reset_stats')
def reset_stats():
    coll = get_db()
    if coll is not None:
        coll.delete_one({'user': 'default'})
    session.pop('stats', None)
    logger.info("Stats reset", extra={"event": "reset_stats"})
    return redirect(url_for('index'))

@app.route('/health')
def health():
    try:
        coll = get_db()
        if coll is None:
            raise Exception("No DB connection")
        stats_doc = coll.find_one({"user": "default"})
        user_count = coll.count_documents({})
        logger.info("Health check", extra={"event": "health", "status": "ok"})
        return jsonify({
            "status": "ok",
            "user_count": user_count,
            "default_stats": stats_doc.get("stats") if stats_doc else None
        }), 200
    except Exception as e:
        logger.error("Health check failed", extra={"error": str(e)})
        return jsonify({"status": "db_error", "error": str(e)}), 500

@app.route('/echo', methods=['POST'])
def echo():
    try:
        data = request.get_json(force=True)
        logger.info("Echo endpoint hit", extra={"event": "echo", "received": data})
        return jsonify({"received": data})
    except Exception as e:
        logger.error("Echo endpoint error", extra={"error": str(e)})
        return jsonify({"error": str(e)}), 400

@app.route('/person/<name>', methods=['GET', 'PUT', 'DELETE'])
def person(name):
    coll = get_db()
    if coll is None:
        logger.error("Person endpoint: DB not available", extra={"event": "person", "user": name})
        return jsonify({'error': 'Database not available'}), 500

    if request.method == 'GET':
        doc = coll.find_one({'user': name})
        if doc:
            logger.info("Person GET", extra={"event": "person_get", "user": name})
            return jsonify({'user': name, 'stats': doc.get('stats', {})})
        else:
            logger.warning("Person GET: User not found", extra={"event": "person_get", "user": name})
            return jsonify({'error': 'User not found'}), 404

    elif request.method == 'PUT':
        data = request.get_json(force=True)
        if not data or not isinstance(data, dict):
            logger.warning("Person PUT: Invalid data", extra={"event": "person_put", "user": name})
            return jsonify({'error': 'Invalid data'}), 400
        coll.update_one({'user': name}, {'$set': {'stats': data}}, upsert=True)
        logger.info("Person PUT: Stats updated", extra={"event": "person_put", "user": name})
        return jsonify({'message': 'Stats updated', 'user': name})

    elif request.method == 'DELETE':
        result = coll.delete_one({'user': name})
        if result.deleted_count == 1:
            logger.info("Person DELETE: User deleted", extra={"event": "person_delete", "user": name})
            return jsonify({'message': 'User deleted'})
        else:
            logger.warning("Person DELETE: User not found", extra={"event": "person_delete", "user": name})
            return jsonify({'error': 'User not found'}), 404

if __name__ == '__main__':
    debug = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
    logger.info("Starting Blackjack Flask app", extra={"event": "startup", "debug": debug})
    app.run(debug=debug, host="0.0.0.0", port=5000)
