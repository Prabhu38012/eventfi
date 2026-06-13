from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
CORS(app)

# ─── Health Check ─────────────────────────────────────────────
@app.route('/health')
def health():
    return jsonify({
        'status':  'ok',
        'app':     'EventFi AI Service',
        'version': '1.0.0'
    })

# ─── Routes — uncomment as you build each Phase 8 feature ─────
# from routes.recommendation import recommendation_bp
# from routes.search         import search_bp
# from routes.chatbot        import chatbot_bp
# from routes.demand         import demand_bp
# from routes.sentiment      import sentiment_bp
# from routes.fake_detector  import fake_bp

# app.register_blueprint(recommendation_bp)
# app.register_blueprint(search_bp)
# app.register_blueprint(chatbot_bp)
# app.register_blueprint(demand_bp)
# app.register_blueprint(sentiment_bp)
# app.register_blueprint(fake_bp)

if __name__ == '__main__':
    port  = int(os.environ.get('PORT', 8000))
    debug = os.environ.get('NODE_ENV', 'development') == 'development'
    print(f'\n[AI] EventFi AI Service running on port {port}\n')
    app.run(host='0.0.0.0', port=port, debug=debug)
