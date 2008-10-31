From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Fri, 31 Oct 2008 13:32:43 -0700
Subject: [Lustre-devel] HSM comments
In-Reply-To: <490732D1.8060103@cea.fr>
References: <4905F121.6000501@cea.fr> <4906488A.8030006@sun.com>
	<490732D1.8060103@cea.fr>
Message-ID: <490B6B6B.1070401@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Our conclusions from the meeting about HSM unlink, from 
http://arch.lustre.org/index.php?title=HSM_Migration


      5.4 unlink

   1. A client issues an unlink for a file to the MDT.
   2. The MDT includes the "hsm_exists" bit in the changelog unlink entry
   3. The policy engine determines if the file should be removed from HSM
   4. Policy engine sends HSMunlink FID to coordinator via MDT ioctl
         1. Yuck - we can't do direct ioctls on the MDT from a client
            node. We can only do ioctls on a file.

                maybe we need to implement a .lustre/device/XXX dir,
                where all MDT/OSTs are listed, and act as stub files for
                handling ioctls. 
                or maybe policy engine talks to agent / tool directly
                for unlinks? 

   5. The coordinator sends a request to one of its agent for the
      corresponding removal.
   6. The agent spawns the HSM tool to do this removal.
   7. When HSM removal is complete, policy engine cancels changelog
      unlink record
         1. How does agent/HSM tool signal to policy engine that HSM
            removal is complete?
   8. In case of agent crash, unlink record will remain uncancelled in
      the changelog; policy engine should restart processing at the
      first uncancelled record.


There's two open issues:
- How for policy engine to tell coordinator to unlink an HSM object, 
when no corresponding object exists on the MDT for us to ioctl() on
    -which coordinator to talk to for CMD?
    -since unlink isn't data movement, maybe all unlinks can be 
originated from policy engine directly?  (direct call to HSMunlinkHelper 
executable)
- How does HSMunlinkHelper return a signal to the policy engine that the 
removal is complete
    -if policy engine directly calls HSMunlinkHelper this is easy...

DEGREMONT Aurelien wrote:
>
>>> * HSM dirty bit.
>>>
>>> - should be updated with laziness.
>>> - Is it possible to implement it like the lazy file size? That means,
>>> manage the dirty bit, per OST object, and lazily update it on the MDT?
>>>       
>> Since file mtime/size is already updated this way, we can just use any 
>> attr change as the dirty indicator; we don't need an actual bit per 
>> object.  
>>     
> Dirty means data were changed, not metadata.
>   
Actually a file is dirty if either changed, depending on what you are 
storing in HSM:
filename / path?
EAs?
My point was that you can use the mtime attr change as an indicator that 
some data
possibly changed.  It is not sufficient to show that it absolutely has 
changed, so
policy engine could do something else to try to verify the change, or 
simply assume
that the file is changed, mark it dirty, and reschedule for copyout -- 
no real harm done.
Yes, I agree it would be ideal to have a true verifyable "this file has 
changed" versioning,
but since that doesn't exist yet, I don't think we need to hold up HSM 
development for it.
