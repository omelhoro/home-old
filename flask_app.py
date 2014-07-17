from flask import Flask,request
from flask import render_template
import re
app = Flask(__name__)

# @app.route("/")
# def index():
#     return render_template("base.html")
pages=(
       ("/",("about_me","About me")),
    ("/resumee",("","Resumee")),
    ("/projects/<pro>",( 
                        (("sylls","Syllables"),
                         ("slovdesc","Slovene"),
                         ("comsoon","Praat & xml"),
                         )
                        ,"Projects")),
    ("/sempapers",("","Study")),
    ("/workviz",("","Work samples (viz)")), 
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

fns=map(create_route,pages) 
        
if __name__ == "__main__": 
    app.debug = True
    app.run()