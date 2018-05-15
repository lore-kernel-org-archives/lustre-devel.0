From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 16:17:02 +0100 (BST)
Subject: [lustre-devel] Regression with delayed_work in sec_gc
Message-ID: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Dmitry has backported your upstream commit 

be3c64da248b1ada2bbcfc3855f07536d8087acb ( ptlrpc: use workqueue for 
pinger)

and Sebastien tried out the change which can be seen at 
https://review.whamcloud.com/#/c/31724. Sebastien is having issues with 
unloading osc, mdc, ost or mdt kernel modules. He writes that he activated 
Kerberos for my file system, did some IOs, then tried to unmount the 
client and the  targets. Unfortunately, on some occasions, while 
unmounting, the mdc module for instance has extra references (as shown by 
'lsmod'), and cannot be unloaded. After a while, the extra references are 
dropped, and the  module can be unloaded. It also happens on occasions on 
server side, for the mdt or ost modules. I tried destroy_workqueue but
that made things worst :-( Do you know what is going on?
