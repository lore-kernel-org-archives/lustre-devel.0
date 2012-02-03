From: Charles Cummings <Ccummings@harthosp.org>
Date: Fri, 03 Feb 2012 17:30:35 -0500
Subject: [Lustre-devel] Lustre 1.8.7 - Setup prototype in Research field -
	STUCK !
Message-ID: <4F2C19BB020000CD00074CE1@gwmail1.harthosp.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Everyone,
 
being the local crafty busy admin for a neuroscience research branch, Lustre seems the only way to go however I'm a bit stuck and need some thoughtful guidance.
 
My goal  is to setup a virtual OS environment which is a replica of our 
Direct attached storage head node running SLES 11.0 x86 64   Kernel:  2.6.27.19-5 default #1 SMP
and our (2) Dell blade clusters running CentOS 5.3 x86 64   Kernel: 2.6.18-128.el5 #1 SMP
which I now have running as a) SLES 11 same kernel MDS  b) SLES 11 same kernel OSS   and   c) CentOS 5.3 x86 65 same kernel
and then get Lustre running across it.
 
The trouble began when i was informed that the Lustre rpm kernel numbers MUST match the OS kernel number EXACTLY due to modprobe errors and mount errors on the client,
and some known messages on the servers after the rpm installs.
 
My only direct access to Oracle Lustre downloads is through another person with an Oracle ID who's not very willing to help - i.e. this route is painful
 
So to explain why I'm stuck:
 
a) access to oracle downloads is not easy
b) there is so much risk with altering kernels, given all the applications and stability of the environment you could literally trash the server and spend days recovering - in addition to it being the main storage / resource for research 
c) I can't seem to find after looking Lustre RPMs that match my kernel environment specifically, i.e. the SLES 11 AND CENTOS 5.3
d) I've never created rpms to a specific kernel version and that would be a deep dive into new territory and frankly another gamble
 
What's the least painful and least risky to get Lustre working in this prototype which will then lend to production (equally least painful) given these statements - Help !
Cliff, I could use some details on how specifically wamcloud can fit this scenero - and thanks for all the enlightenment.
 
 
thanks for your help
Charles 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120203/abbe092a/attachment.htm>
