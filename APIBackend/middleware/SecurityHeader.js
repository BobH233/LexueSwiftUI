const AddSecurityHeader = (req, res, next) => {
    res.removeHeader("X-Powered-By");
    res.set({
        "X-Content-Type-Options": "nosniff",
		"Referrer-Policy": "strict-origin",
		"Feature-Policy": "default 'none'",
		"Content-Security-Policy": "default 'none'",
		"X-XSS-Protection": "1; mode=block",
        "X-Powered-By": "BobHEngine"
    });
    if(!process.env.LOCALDEV){
        res.set({
            "Access-Control-Allow-Origin": process.env.FRONTDOMAIN,
            "Access-Control-Allow-Methods": "GET, POST"
        });
    }else{
        res.set({
            "DEVMODE": "true",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST"
        });
    }
    next();
}

module.exports = AddSecurityHeader;