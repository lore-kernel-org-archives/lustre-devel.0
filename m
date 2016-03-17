From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 17 Mar 2016 23:09:44 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
Message-ID: <20160317200944.GA25388@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Peng Tao,

The patch d7e09d0397e8: "staging: add Lustre file system client
support" from May 2, 2013, leads to the following static checker
warning:

	drivers/staging/lustre/lustre/obdecho/echo_client.c:1040 cl_echo_enqueue0()
	error: 'lck' dereferencing possible ERR_PTR()

drivers/staging/lustre/lustre/obdecho/echo_client.c
  1034  
  1035          lck = cl_lock_request(env, io, descr, "ec enqueue", eco);
                      ^^^^^^^^^^^^^^^
This can return either an ERR_PTR or NULL.  It's not clear from the
documentation what that means.  There is actually some documentation
for this function though so that's good.


  1036          if (lck) {
                    ^^^
Ugh.  Success handling.

  1037                  struct echo_client_obd *ec = eco->eo_dev->ed_ec;
  1038                  struct echo_lock *el;
  1039  
  1040                  rc = cl_wait(env, lck);
  1041                  if (rc == 0) {
                            ^^^^^^^
More success handling and nested indents.  If we flip these around to
test for failure instead the code becomes much clearer.

  1042                          el = cl2echo_lock(cl_lock_at(lck, &echo_device_type));
  1043                          spin_lock(&ec->ec_lock);
  1044                          if (list_empty(&el->el_chain)) {
  1045                                  list_add(&el->el_chain, &ec->ec_locks);
  1046                                  el->el_cookie = ++ec->ec_unique;
  1047                          }
  1048                          atomic_inc(&el->el_refcount);
  1049                          *cookie = el->el_cookie;
  1050                          spin_unlock(&ec->ec_lock);
  1051                  } else {
  1052                          cl_lock_release(env, lck, "ec enqueue", current);
  1053                  }
  1054          }
  1055          return rc;
  1056  }

regards,
dan carpenter
