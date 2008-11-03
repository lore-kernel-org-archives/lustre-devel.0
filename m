From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Mon, 03 Nov 2008 16:30:02 +0100
Subject: [Lustre-devel] HSM comments
In-Reply-To: <490B6B6B.1070401@sun.com>
References: <4905F121.6000501@cea.fr> <4906488A.8030006@sun.com>
	<490732D1.8060103@cea.fr> <490B6B6B.1070401@sun.com>
Message-ID: <490F18FA.5040509@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
>      5.4 unlink
>
>   1. A client issues an unlink for a file to the MDT.
>   2. The MDT includes the "hsm_exists" bit in the changelog unlink entry
>   3. The policy engine determines if the file should be removed from HSM
>   4. Policy engine sends HSMunlink FID to coordinator via MDT ioctl
>         1. Yuck - we can't do direct ioctls on the MDT from a client
>            node. We can only do ioctls on a file.
>
>                maybe we need to implement a .lustre/device/XXX dir,
>                where all MDT/OSTs are listed, and act as stub files for
>                handling ioctls.                or maybe policy engine 
> talks to agent / tool directly
>                for unlinks?

Can't we add an ioctl on /dev/obd or /mnt/lustre root dir ? or even on 
.lustre/fid and passing the fid in ioctl args?
I'm not fond of .lustre/device/XXX dirs...
>   5. The coordinator sends a request to one of its agent for the
>      corresponding removal.
>   6. The agent spawns the HSM tool to do this removal.
>   7. When HSM removal is complete, policy engine cancels changelog
>      unlink record
>         1. How does agent/HSM tool signal to policy engine that HSM
>            removal is complete?
>   8. In case of agent crash, unlink record will remain uncancelled in
>      the changelog; policy engine should restart processing at the
>      first uncancelled record.
>
>
> There's two open issues:
> - How for policy engine to tell coordinator to unlink an HSM object, 
> when no corresponding object exists on the MDT for us to ioctl() on
>    -which coordinator to talk to for CMD?
If we implement an ioctl like
ioctl(.lustre/fid, HSMUnlink, fid=0x0000121561), can the API find the 
good MDT from the FID ? FLD can do this for an already removed file?)

> - How does HSMunlinkHelper return a signal to the policy engine that 
> the removal is complete
>    -if policy engine directly calls HSMunlinkHelper this is easy...
I think there is a more general issue concerning feedback for the 
PolicyEngine. Surely the PolicyEngine will need information for other 
request it sent to the Coordinator. We should think of a more general 
mechanism to inform it of the success or failure of its requests.

Should the HSM (succesfull) event become changelog 
events....(hsm_copyin/hsm_copyout/hsm_remove)? Can another program be 
interested in such events?


Aur?lien
