/*
    mcloud_agent
    depends:
        mlib.cloud.account.js
            cryptojs_tripledes.js
            cryptojs_pad-nopadding-min.js
            mlib.crypt.dh.js
            mlib.crypt.md5.js
            mlib.core.rpc.js
                mlib.core.codec.js
                mlib.core.evt.js
   
    ----history----------
    author: chengzhiyong date: 2014-08-13 action: create
*/
(function(window){
    var l_srv = "", //域名
		l_devs = [],  //设备列表
		mcloud_account = window.mcloud_account,
        l_fix = null; //{type:funcion(type){},/* return fixed type; */req:{function(type,req){ /* return fixed req data */},ack:{function(type,ack){ /* return fixed ack data */}

    function send_msg(type, data, ref, on_ack)
    {
        //if(!l_srv){ mcloud_account.set_srv(window.location.host); }
        return mcloud_account.send_msg(l_fix?l_fix.type(type):type, l_fix?l_fix.req(type, data):data, ref, 
            l_fix?function(ack,ref){on_ack(l_fix.ack(type,ack),ref)}:on_ack); 
    }
    function create_nid()
    { 
    	return mcloud_account.create_nid(); 
    }
    function pwd_encrypt(pwd_md5_hex){ 
    	return mcloud_account.pwd_encrypt(pwd_md5_hex); 
    }
    function get_ret (msg) {
        var ret = (msg && msg.data)?(msg.data.ret || msg.data.result):null ;
        if (Object.prototype.toString.call(ret) === "[object String]") {return ret;} 
        else{return s_ret = ret?(ret.reason || ret.sub|| ret.code):null;}
    }

    function dev_add (obj, ref, on_ack) {
    	var pwd_md5_hex = mmd5.hex(obj.pass || "");
      	send_msg("ccm_dev_add", {sess:{nid:create_nid()}, sn:obj.sn,pwd:pwd_encrypt(pwd_md5_hex)},ref,
                function(msg,ref){
                	var result=get_ret(msg);
               		on_ack({result:result,info:msg.data.info},ref);
								});
    }
    
    function nick_set (obj, ref, on_ack) {
        send_msg("ccm_nick_set", {sess:{nid:create_nid(), sn:obj.sn},nick:obj.name},ref,
            function(msg,ref) {on_ack({result:get_ret(msg)},ref);});
    }
    
    function dev_passwd_set (obj, ref, on_ack) {
        var old_pass = (obj.old_pass &&window.mmd5.hex(obj.old_pass));
        var new_pass = (obj.new_pass &&window.mmd5.hex(obj.new_pass));
        send_msg("ccm_pwd_set", {sess:{nid:create_nid(), sn:obj.sn},
            user:{username:obj.sn,old_pwd:pwd_encrypt(old_pass),pwd:pwd_encrypt(new_pass),level:"",guest:obj.is_guest?1:0}},ref,
            function(msg,ref) {on_ack({result:get_ret(msg)},ref);});
    }
    
    function net_get (obj, ref, on_ack) {
        var networks,dns;
        send_msg("ccm_net_get", {sess:{nid:create_nid(), sn:obj.sn},select:obj.select,
        	tokens:["eth0", "ra0"], items:["all", "all"], force_scan:1},ref,
            function(msg,ref) {
                var result=get_ret(msg);
                if(result == "")
                {
                    var msg=msg.data?msg.data.info:"";
                    networks=msg.ifs;
                    dns=msg.dns;
                }
                on_ack({result:result,networks:networks,dns:dns},ref);
            });
    }
    
    function net_set (obj, ref, on_ack) {
        var info={ifs:obj.networks,dns:obj.dns};
        send_msg("ccm_net_set", {sess:{nid:create_nid(), sn:obj.sn},info:info},ref,
            function(msg,ref) {on_ack({result:get_ret(msg)},ref);});
    }

    function set_srv(srv)
    {
        l_srv=srv;  
    }

    function cap_get(obj,ref,on_ack){
        send_msg("ccm_cap_get",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},id:obj.id},ref,function(msg,ref){
            var result = get_ret(msg);
            if(result == "" && msg.data){
                on_ack({result:result,data:msg.data},ref);
            }
            });
    }


    function exdev_get(obj,ref,on_ack){
            send_msg("ccm_exdev_get",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},flag:obj.flag,start:obj.start,counts:obj.counts},ref,function(msg,ref){
                var result = get_ret(msg);
                if(result == "" && msg.data){
                    on_ack({result:get_ret(msg),data:msg.data},ref);
                }else{
                    on_ack({result:get_ret(msg)},ref);
                }
            });
        }

    function  exdev_discover(obj,ref,on_ack){
            send_msg("ccm_exdev_discover",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},flag:obj.flag,timeout:obj.timeout,interval:obj.interval},ref,
                function(msg,ref){
                    var result = get_ret(msg);
                    if(result == "" && msg.data){
                        on_ack({result:result,data:msg.data},ref);
                    }
                });
        }

    function exdev_add(obj,ref,on_ack){
            send_msg("ccm_exdev_add",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},id:obj.id,model:obj.model,timeout:obj.timeout,interval:obj.interval},ref,
                function(msg,ref){
                    var result = get_ret(msg);
                    if(result == "" && msg.data){
                        on_ack({result:result,data:msg.data},ref);
                    }    
            });

        }


    function exdev_del(obj,ref,on_ack){
            send_msg("ccm_exdev_del",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},id:obj.id},ref,function(msg,ref){
                var result = get_ret(msg);
                if(result == "" && msg.data){
                    on_ack({result:result,data:msg.data},ref);
                }
            });
        }

    function cap_get(obj,ref,on_ack){
            send_msg("ccm_cap_get",{sess:{nid:mcloud_account.create_nid(),sn:obj.sn},id:obj.id},ref,function(msg,ref){
              var result = get_ret(msg);
                if(result == "" && msg.data){
                    on_ack({result:result,data:msg.data},ref);
                }
            });
        }
 
    function submit_feedback(obj,ref,on_ack){
         if(obj.upload_pic){
         send_msg({type:"ctck_create_ticket_req",to:"ctck",feedback_srv:obj.feedback_srv},{nid:"",title:obj.title,series:obj.series,content_item:obj.content_item,upload_pic:obj.upload_pic},ref,function(msg,ref){
                  if(msg.data.result == "" && msg.data){
                  on_ack({result:msg.data.result,data:msg.data},ref);
                  }
                  });
         }else{
         send_msg({type:"ctck_create_ticket_req",to:"ctck",feedback_srv:obj.feedback_srv},{nid:"",title:obj.title,series:obj.series,content_item:obj.content_item},ref,function(msg,ref){
                  var result = get_ret(msg);
                  if(result == "" && msg.data){
                  on_ack({result:result,data:msg.data},ref);
                  }
                  });
         }
         }

    function writeObj(obj){
          var description = "";
          for(var i in obj){
           var property=obj[i];
           description+=i+" = "+property+"\n";
          }
          alert(description);
         }

    function feedback_series_get(obj,ref,on_ack){
//            send_msg({type:"ctck_get_series_req",to:"ctck"},{nid:mcloud_account.create_nid(),lang:obj.lang},ref,function(msg,ref){//LKK modify
            send_msg({type:"ctck_get_series_req",to:"ctck",feedback_srv:obj.feedback_srv},{lang:obj.lang},ref,function(msg,ref){
//                var result = get_ret(msg);
                if(msg.data.result == "" && msg.data){
                    on_ack({result:msg.data.result,data:msg.data},ref);
                }
            });
        }
 
 
 window.mcloud_agent = {
        set_srv:set_srv,
        /* refer mcloud_account */
        /* pwd_encrypt(pwd_md5_hex) */
        pwd_encrypt:pwd_encrypt,
        /* create_nid() */
        create_nid:create_nid,
        /* send_msg("type", {xxx}, ref, on_ack) ret:{message}*/
        send_msg: send_msg,
        /* dev_add({sn:"xxx",pass:"xxx"},ref,on_ack) ret{result:""}*/
        dev_add:dev_add,
        /* nick_set({sn:"xxx",name:""},ref,on_ack) ret{result:""}*/
        nick_set:nick_set,
        /* dev_passwd_set({sn:"",old_pass:"xxx",new_pass:"xxx",is_guest:"xxx"},ref,on_ack) ret{result:""}*/
        dev_passwd_set:dev_passwd_set,
        /* net_get({sn:"xxx"},ref,on_ack) ret{result:"",networks:"",dns:""}*/
        net_get:net_get,
        /* net_set({sn:"xxx",networks:"",dns:""},ref,on_ack) ret{result:""}*/
        net_set:net_set,
        cap_get:cap_get,
        submit_feedback:submit_feedback,
        feedback_series_get:feedback_series_get,
    };
})(window);
