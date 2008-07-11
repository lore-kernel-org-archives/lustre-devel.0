From: Jacques-Charles Lafoucriere <jc.lafoucriere@cea.fr>
Date: Fri, 11 Jul 2008 16:31:41 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C4959727.4DA5%peter.braam@sun.com>
References: <C4959727.4DA5%peter.braam@sun.com>
Message-ID: <48776ECD.3000501@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Peter Braam wrote:
>
> There is a rule in Lustre - no scanning, ever.  This rule will not be broken
> by HSM.  
>   
If a site wants to connect an HSM to an existing file system (close to 
be full)
how do we do without fast scanning ?
We cannot restrict the use of HSM binding only on new file systems

JC
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080711/8f0e1d63/attachment.htm>
