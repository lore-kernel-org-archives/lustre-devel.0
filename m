From: David Binderman <dcb314@hotmail.com>
Date: Mon, 14 Mar 2016 19:36:33 +0000
Subject: [lustre-devel]
 linux-4.5/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c:880: wrong %
 specifier ?
Message-ID: <DUB128-W424197BF214665EBD6F6C39C880@phx.gbl>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello there,

[linux-4.5/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c:880]: (warning) %d in format string (no. 1) requires 'int' but the argument type is 'unsigned int'.??? 

Source code is

??? return sprintf(buf, "%d\n", ldlm_cancel_unused_locks_before_replay);

but

extern unsigned int ldlm_cancel_unused_locks_before_replay;

Suggest use %u, not %d.


Regards

David Binderman
 		 	   		  
