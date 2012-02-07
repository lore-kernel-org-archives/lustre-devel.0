From: Kevin Van Maren <KVanMaren@fusionio.com>
Date: Tue, 7 Feb 2012 10:26:08 -0700
Subject: [Lustre-devel] [Lustre-discuss] Lustre 1.8.7 - Setup prototype
 in Research field -	STUCK !
In-Reply-To: <4F2C19BB020000CD00074CE1@gwmail1.harthosp.org>
References: <4F2C19BB020000CD00074CE1@gwmail1.harthosp.org>
Message-ID: <BF1E0D33-9545-4780-B996-BA32DB4E9810@fusionio.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You can get the Oracle downloads from:
http://downloads.lustre.org/public/lustre/v1.8/lustre_1.8.7/

Basically, build Lustre for your kernel on the clients, but use the Lustre server kernel on the servers.

Kevin


On Feb 7, 2012, at 9:09 AM, "Charles Cummings" <Ccummings@harthosp.org> wrote:

> Hello Everyone,
>  
> being the local crafty busy admin for a neuroscience research branch, Lustre seems the only way to go however I'm a bit stuck and need some thoughtful guidance.
>  
> My goal  is to setup a virtual OS environment which is a replica of our
> Direct attached storage head node running SLES 11.0 x86 64   Kernel:  2.6.27.19-5 default #1 SMP
> and our (2) Dell blade clusters running CentOS 5.3 x86 64   Kernel: 2.6.18-128.el5 #1 SMP
> which I now have running as a) SLES 11 same kernel MDS  b) SLES 11 same kernel OSS   and   c) CentOS 5.3 x86 65 same kernel
> and then get Lustre running across it.
>  
> The trouble began when i was informed that the Lustre rpm kernel numbers MUST match the OS kernel number EXACTLY due to modprobe errors and mount errors on the client,
> and some known messages on the servers after the rpm installs.
>  
> My only direct access to Oracle Lustre downloads is through another person with an Oracle ID who's not very willing to help - i.e. this route is painful
>  
> So to explain why I'm stuck:
>  
> a) access to oracle downloads is not easy
> b) there is so much risk with altering kernels, given all the applications and stability of the environment you could literally trash the server and spend days recovering - in addition to it being the main storage / resource for research
> c) I can't seem to find after looking Lustre RPMs that match my kernel environment specifically, i.e. the SLES 11 AND CENTOS 5.3
> d) I've never created rpms to a specific kernel version and that would be a deep dive into new territory and frankly another gamble
>  
> What's the least painful and least risky to get Lustre working in this prototype which will then lend to production (equally least painful) given these statements - Help !
> Cliff, I could use some details on how specifically wamcloud can fit this scenero - and thanks for all the enlightenment.
>  
>  
> thanks for your help
> Charles 
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss

Confidentiality Notice: This e-mail message, its contents and any attachments to it are confidential to the intended recipient, and may contain information that is privileged and/or exempt from disclosure under applicable law. If you are not the intended recipient, please immediately notify the sender and destroy the original e-mail message and any attachments (and any copies that may have been made) from your system or otherwise. Any unauthorized use, copying, disclosure or distribution of this information is strictly prohibited.  Email addresses that end with a ?-c? identify the sender as a Fusion-io contractor.
