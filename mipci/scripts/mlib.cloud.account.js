/*
    mcloud_account
    
    base on:
    cryptojs_tripledes.js
    cryptojs_pad-nopadding-min.js

    mlib.core.base.js
    mlib.core.codec.js
    mlib.core.evt.js
    mlib.core.rpc.js
    mlib.crypt.dh.js
    mlib.crypt.md5.js
    
    ----history----------
    author: chengzhiyong date: 2014-08-13 action: create
    
*/

(function(window){
    var l_srv = window.location.host/* set by kugle */, l_usr = "", l_pwd_md5_hex = "",
        l_qid = "",
        l_tid = 0, l_lid = 0, l_sid = 0, l_seq = 0, l_addr = "", l_share_key = "", l_host = "", l_from_handle = 0,
        ret_err_accounts_nid_invalid = "accounts.nid.invalid",
        ret_err_accounts_sid_invalid = "accounts.sid.invalid",
        ret_err_accounts_lid_invalid = "accounts.lid.invalid",
        ret_err_accounts_sess_invalid = "InvalidSession",
        s_cacs_login_req = "cacs_login_req",
        s_cacs_reg_req = "cacs_reg_req",
        ret_err_refer_relogin = [ret_err_accounts_nid_invalid, ret_err_accounts_sid_invalid, ret_err_accounts_lid_invalid, ret_err_accounts_sess_invalid],
        CryptoJS = window.CryptoJS,
        mmd5 = window.mmd5,
        mcodec = window.mcodec,
        mrpc = window.mrpc;


    function get_share_key(share_key)
    {
        l_share_key = share_key;
    }
    function get_sid(sid)
    {
        l_sid = sid;
    }
    
    function get_srv(srv)
    {
        return l_srv = srv;
    }
            
    function pwd_encrypt( pwd_md5_hex )
    {
    		var xxx = CryptoJS.enc.Hex.parse(pwd_md5_hex);
        return CryptoJS.DES.encrypt(CryptoJS.enc.Hex.parse(pwd_md5_hex), CryptoJS.enc.Hex.parse(mmd5.hex(l_share_key)),
                                     {iv:CryptoJS.enc.Hex.parse('0000000000000000'), padding: CryptoJS.pad.NoPadding}).ciphertext.toString();
    }
    
    function create_nid_ex(type/* 0:by sid, 2: by lid */)
    {/* \todo: if support type==>tid , plz change following line. */
        return mcodec.nid( ++l_seq, type?l_lid:l_sid, l_share_key, type, null, null, mmd5, "hex" );
    }
    
    function create_nid()
    { 
        return create_nid_ex(0); 
    }

    function do_call(type, data, ref, on_ack)
    {

        if(type.to){
             if(type.to == "ctck"){
                //alert("In Type.to=ctck");LKK
             //96.46.4.26  端口10080    国内的是61.147.109.92 国外的是96.46.4.26 之前的那个mip公网上统一改为node
//             mrpc.call({srv: "http://" + "96.46.4.26:10080/ctck", type:type.type, data:data,
//                       ref:ref, "static":false, way:"from", qid:l_qid, on_ack:on_ack});
//             mrpc.call({srv: "http://" + "192.168.3.120:10080/ctck", type:type.type, data:data,
//                       ref:ref, "static":false, way:"from", qid:l_qid, on_ack:on_ack});
//             mrpc.call({srv: "http://" + "192.168.1.75:10080/ctck", type:type.type, data:data,
//                       ref:ref, "static":false, way:"from", qid:l_qid, on_ack:on_ack});
             mrpc.call({srv: type.feedback_srv, type:type.type, data:data,
                       ref:ref, "static":false, way:"from", qid:l_qid, on_ack:on_ack});
             }
             else{
             mrpc.call({srv:window.location.protocol + "//" + "192.168.1.62:9080" + "/", to:type.to, type:type.type, data:data,
                       ref:ref, "static":false, way:"json", qid:l_qid, on_ack:on_ack});
             }
    }
        else
        {
            if(l_qid)
            {
            	  if(type=="cpns_get_req")
            	  {
            	  	mrpc.call({srv:ref.remote_ip, to:"cpns", type:type, data:data, 
    	                  ref:ref, "static":false, way:"json", qid:l_qid, on_ack:on_ack});
            	  }
            	  else
            	  {
    	            mrpc.call({srv:window.location.protocol + "//" + l_srv + "/", to:"ccm", type:type, data:data, 
    //                mrpc.call({srv:"http://" + l_srv + "/", to:"ccm", type:type, data:data, 
    	                  ref:ref, "static":false, way:"json", qid:l_qid, on_ack:on_ack});
                }
            }
            else
            {
            		if(type=="cpns_get_req")
            		{
            			mrpc.call({srv:ref.remote_ip, to:"cpns", type:type, data:data, 
    	                  ref:ref, "static":false, way:"json", on_ack:on_ack});
            		}
            		else
            		{
    	            //mrpc.call({srv:window.location.protocol + "//" + l_srv + "/", to:"ccm", type:type, data:data,
                  mrpc.call({srv:l_srv, type:type, data:data,
    	                  ref:ref, "static":false, way:"json", on_ack:on_ack});
                }
            }
        }
    }

    function send_msg(type, data, ref, on_ack)
    {
        do_call(type, data, ref, 
        function(msg, ref){
            on_ack(msg, ref);
        });
    }
    
    function pwd_set (old_pass,new_pass,is_guest,ref,on_ack) {
    	var old_pass = (old_pass &&mmd5.hex(old_pass));
    	var new_pass = (new_pass &&mmd5.hex(new_pass));
      	send_msg("cacs_passwd_req", {nid:create_nid(),old_pass:pwd_encrypt(old_pass),new_pass:pwd_encrypt(new_pass),guest:is_guest?1:0},ref,
                function(msg,ref) {on_ack(msg,ref);});
    }
    
    window.mcloud_account = {
        get_srv:get_srv,  /* get_srv(srv) */
        get_sharekey:get_share_key,
        get_sid:get_sid,
        pwd_encrypt:pwd_encrypt,/* pwd_encrypt(pwd_md5_hex) */   
        create_nid_ex:create_nid_ex,/* create_nid_ex(type) type:0 by sid, 2: by lid */
        create_nid:create_nid,
        pwd_set:pwd_set,
        send_msg:send_msg,/* send_msg(type, data, ref, on_ack) */
    };
})(window);