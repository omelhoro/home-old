from flask import Flask,request,redirect
from flask import render_template
import re
app = Flask(__name__)

from rustress.webapi_blue import setup_rs
app_rs=setup_rs()
app.register_blueprint(app_rs)

# @app.route("/")
# def index():
#     return render_template("base.html")
pages=(
       ("/",("about_me","About me")),
    ("/resumee",("","Resumee")),
    ("/projects/<pro>",( 
                        (
                         ("sylls","Syllables (BA-App)"),
                         ("syllsviz","LingViz"),
                         ("slovdesc","Slovene"),
                         ("praatxml","Praat & xml"),
                         ("rustress","Russian stress"),
                         ("foreignrus","Claiming Respect"),
                         )
                        ,"Projects")),
    ("/sempapers",("","Study")),
    ("/workviz",("","Work samples")), 
       )

def create_route(routview):
    
    def url(viewpath):
        def level(pro=None):
            if pro is None:
                return render_template(viewpath+".html",pages=pages,path=request)
            else:
                return render_template(re.sub("<.+>","",viewpath)+pro+".html",pages=pages,path=request)
        return level 
 
    route,(view,txt)=routview
    if isinstance(view,tuple) or not view:
        view=route 
    f=url(view)  
    f.__name__=view
    return app.route(route)(f)


#redirection for dart app, dart doest support relative links, but hard links then need symlinks, so its easier to simple redirect
@app.route("/static/css/selfpoly.css")
def redir():
    return redirect("/static/slov-apps/build/web/static/css/selfpoly.css")
fns=map(create_route,pages) 
        
if __name__ == "__main__": 
    app.debug = True
    app.run()
