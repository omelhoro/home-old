from flask import Flask
from flask import render_template
app = Flask(__name__)

@app.route("/")
def index():
    return render_template("base.html")

@app.route("/about_me")
def interests():
    return render_template("about_me.html")

@app.route("/resumee")
def resumee():
    return render_template("resumee.html")

@app.route("/projects")
def projects():
    return render_template("projects.html")

if __name__ == "__main__":
    app.run()