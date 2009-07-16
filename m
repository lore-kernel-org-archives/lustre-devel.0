From: Scott Atchley <atchley@myri.com>
Date: Thu, 16 Jul 2009 17:10:44 -0400
Subject: [Lustre-devel] Testing LNET
Message-ID: <9A79889B-CA4B-43E7-9824-79A1F7949AFE@myri.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I have implemented handling of hosts with different PAGE_SIZE in  
MXLND. I am running tests to make sure that I did not accidentally  
break something else. So far, I have been using lctl and pinging back  
and forth as well as with obdecho (using loadgen).

When running loadgen tests or lctl test_brw with loadgen's echosrv  
running, if I kill a host (either client or server) and bring it back  
up, LNET seems happy (MXLND reconnects normally), but loadgen does not  
resume. When using lctl test_brw and I restart a server, the client  
reconnects but then fails an assertion when it connects to a new  
server with:

LustreError: 6295:0:(echo_client.c:1341:echo_client_cleanup())  
ASSERTION(eco->eco_refcount == 0) failed

If this the proper way to test a LND? What other methods can you  
suggest?

Thanks,

Scott
