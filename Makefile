install :
	bower install
	npm install
upgrade :
	bcu -a
	bower update

compile :
	grunt compile

run :
	python -m SimpleHTTPServer 8111

production :
	grunt compile
	uglifycss public/d/css/screen.css > public/d/css/c.css
