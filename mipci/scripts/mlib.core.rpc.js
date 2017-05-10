/*
 mrpc
 depends :
 mlib.mcore.codec.js
 mlib.mcore.evt.js


 author: chenghizyong date: 2014-08-31 action: update depends information
 */
/*-----------------mrpc-------------------------------------------------*/
/* mrpc.call({...});  */
(function(window, document, mevt, mcodec){
  var timeout = 300000/* ms */,
      calls  = {},
      xs = {},
      seq = Math.floor((Math.random() * 1000000)),
      fnull = function(){},
      head, timer,
      hfrom_handle,

      meval = function (s){ try{return eval("(" + s + ")"); }catch(e){return null;} };

  function cancel()
  {
    for(var n in calls)
    {
      if(calls[n]){ ack(calls[n], "cancel"); }
    }
  }
  function init()
  {
    timer = setInterval(on_timer, 5000);
    mevt.bind(window, "unload", function()
    {
      clearInterval(timer);
      window.message = null;
      cancel();
      for(var n in xs)
      {
        if(xs[n]){ delete xs[n]; }
      }
    });

    window.message = function(msg)
    {
      var c = calls[msg.to_handle];
      if(c){ ack(c, msg); }
    };
  }

  function on_timer()
  {
    var n, c, tm = (new Date()).getTime();
    for(n in calls)
    {
      if((c = calls[n]) && (c.time < tm)){ ack(c, "timeout"); }
    }
  }

  function ack(c, msg)
  {
    var js = c.js, seq = c.seq, x = c.x;
    delete calls[seq];
    if(js){ delete c.js; if(js.parentNode){ head.removeChild(js); };};
    if(x){ delete c.x; x.abort(); };
    c.on_ack(msg, c.ref);
    if(x){ x.onreadystatechange = fnull; xs[seq] = x; };
  }

  function js_call(c)
  {
    var o = (c.js = document.createElement("script"));
    o.type = "text/javascript";
    o.language = "javascript";
    o.async = true;
    o.src = c.url;
    jQuery.get(o.src, message);
    //(head || (head = (document.getElementsByTagName("head")[0] || document.documentElement))).insertBefore(o, head.firstChild);
  }

  function x_on_rsp(c, x)
  {
    if((c.x == x) && (x.readyState == 4))
    {
      var msg, seq = c.seq;
      if(0 == x.status)
      {/* abort a connection */
        if(calls[seq]/* active connection */){ ack(c, "abort"); };return;
      }
      if((200 == x.status)||(304 == x.status/*opera*/))
      {
        var c, s = x.responseText, b = s.indexOf("("), e = s.lastIndexOf(")");
        if(((e > (b + 2)) && ('{' == s.charAt(b + 1)) && ('}' == s.charAt(e - 1))))
        {
          msg = meval(s.substring(b + 1, e));
        }
      }
      c.x = null;
      ack(c, msg || "error");
      x.onreadystatechange = fnull;
      xs[seq] = x;
    }
  }

  function x_call(c)
  {
	//alert("x-call");LKK
    var n, x;
    for(n in xs){ if(x = xs[n]){ delete xs[n]; x.abort(); break; }};
    x = x || (window.XMLHttpRequest?new XMLHttpRequest():new ActiveXObject("Microsoft.XMLHTTP"));
    x.open(c.param?"post":"get", c.url, true);
    x.onreadystatechange = function(){x_on_rsp(c, x);};
    if(c.param){ x.setRequestHeader("content-type", "application/x-www-form-urlencoded;charset=utf-8"); };
    (c.x = x).send(c.param);
    //alert("x-call-param-->"+c.param);//LKK
    //alert("x-call-url-->"+c.url);//LKK
  }

  function call(msg/*
   srv:"srv_base_url" [if null means "/"],
   to:comp_id|"comp_name" [if null means directly to srv],
   type:"req_message_type" [must],
   static:true|false(default) [is static encode, if null false, if method=post will force changeto false ]
   method:get|post [just for xhr, if null default post],
   from_handle:number[if null, ++seq, default:should be null],
   way:json|xhr|iframe|form|test [if null default cross domain:json or same:domain xhr, not support ifram/form now.]
   data:{}[if null, empty],
   ref:xxx, [if null ignore ],
   on_ack:function(msg, ref){}[must] */)
  {
    if(msg && msg.on_ack && msg.type)
    {
      var dyn = !msg["static"], post = (("json" != msg.way) && ("get" != msg.method)), from_handle = msg["from_handle"], qid = msg["qid"],
          cn = (dyn || post)?"&":"-", cv = ("-" == cn)?"-":"=",
          //app = (msg.srv?"http://61.147.109.92:7080/":"/") + (msg.to?msg.to:"") + "/" +  msg.type,
          app = (msg.srv?msg.srv:"/")  + "/" + msg.type,
          param = "hfrom_handle" + cv + ((null == from_handle)?(++seq):from_handle) + ((null == qid)?"":(cn + "hqid" + cv + qid)) + cn + mcodec.obj_2_url(msg.data, cn),
          c = {seq: seq, on_ack:msg.on_ack, time:((new Date()).getTime() + (msg.timeout?msg.timeout:timeout)),
               url: (post?(app + ".js"):(dyn?(app + ".js?" + param):(app + "/-" + param + ".js"))),
              param: (post?param:""),
               ref: msg.ref};
 
      if("test" != msg.way)
      {
          calls[seq] = c;
          try{
              ("json" == msg.way)?js_call(c):x_call(c);
          }catch(t){ ack(c, "error"); };
      }
      return c.url;
    }
  }

  init();
  window.mrpc = {magic:"rpc", call:call, cancel:cancel};
})(window,document, mevt, mcodec);
/*-----------------mrpc-------------------------------------------------*/