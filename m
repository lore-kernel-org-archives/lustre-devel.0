From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Date: Fri, 16 Mar 2012 14:35:42 +0400
Subject: [Lustre-devel] [wc-discuss] Re: [Twg] Lustre and cross-platform
	portability
In-Reply-To: <4F6311CB.8040506@diamond.ac.uk>
References: <201203151845.q2FIjcXV029439@hedwig.cmf.nrl.navy.mil>
	<C481511A-14DB-4032-9071-82AF5974E263@whamcloud.com>
	<4F624851.6030707@iu.edu> <4F6311CB.8040506@diamond.ac.uk>
Message-ID: <FC3B1D44-ED0D-4EAD-8003-B3E458A46469@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Windows don't have a good OFED port so we anyway will lost a performance.
but using a full client will able to use a striping information and accept a data from a several OST's
with comparing a get a single data stream from a SMB.

Also fuse client will able to run on any OS have a FUSE porting that is any BSD, OpenSolaris, MacOS, in additional to the windows.
That is easy way to maintain a single client for many OS.


On Mar 16, 2012, at 14:11, Gregory Matthews wrote:

> On 15/03/12 19:51, Joshua Walgenbach wrote:
>> For my part, a Lustre client on Windows or OS X would be used mostly
>> for visualization of data, rather than being computed against so a
>> slower user space implementation would be more than sufficient.
>> There are a few applications that are using an SMB exported Lustre
>> filesystem for data collection, but those applications are similarly
>> low bandwidth. It would be nice to remove the SMB server in the
>> middle.
> 
> why bother having a windows client if you lose the performance? We have
> windows based detectors and proprietary windows based analysis software
> that would definitely benefit from higher performance access to lustre
> file systems but replacing existing CIFS servers for no gain seems a bit
> pointless.
> 
> I understand the problems that a native MS client would have, without
> buy-in from Microsoft it would be a nightmare to keep the MS tree and
> the Linux tree in sync. One possible future workaround proposed by
> Whamcloud at last years LUG is pNFS.
> 
> GREG
> 
>> 
>> - -Josh
> 
> 
> -- 
> Greg Matthews            01235 778658
> Senior Computer Systems Administrator
> Diamond Light Source, Oxfordshire, UK
> 
> -- 
> This e-mail and any attachments may contain confidential, copyright and or privileged material, and are for the use of the intended addressee only. If you are not the intended addressee or an authorised recipient of the addressee please notify us of receipt by returning the e-mail and do not use, copy, retain, distribute or disclose the information in or attached to the e-mail.
> Any opinions expressed within this e-mail are those of the individual and not necessarily of Diamond Light Source Ltd. Diamond Light Source Ltd. cannot guarantee that this e-mail or any attachments are free from viruses and we cannot accept liability for any damage which you may sustain as a result of software viruses which may be transmitted in or with the message.
> Diamond Light Source Limited (company no. 4375679). Registered in England and Wales with its registered office at Diamond House, Harwell Science and Innovation Campus, Didcot, Oxfordshire, OX11 0DE, United Kingdom
> 
> 
> 
