From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 16 Nov 2011 17:35:56 -0800
Subject: [Lustre-devel] lustre-devel  packaging - LU-482
In-Reply-To: <CAE97569.14B4%bruce_korb@xyratex.com>
References: <CAE97569.14B4%bruce_korb@xyratex.com>
Message-ID: <ABDA628E-8DA2-4CB8-BC57-371942B013D5@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-16, at 14:22, Bruce Korb <bruce_korb@xyratex.com> wrote:
> 
> I did do a little more due diligence:
> 
> On 11/15/11 7:22 AM, Bruce Korb wrote:
>>> My main question would be - do you _need_ to have access to all of the
>>> headers that you included, or did you simply include all of the headers
>>> because that was the easiest thing to do?  Doing a simple check on the
>>> current master tree, it appears you just copied all of the headers in
>>> libcfs/include, lnet/include, and lustre/include (which total 186 files).
>> 
>> Lets assume I did a minimal approach and only included the necessary
> 
>  libcfs/libcfsutil.h
>  lnet/lnetctl.h
>  lustre/liblustreapi.h
>  lustre/lustre_idl.h
>  test.h
>  utils/obdctl.h
> 
> These are the headers directly #include-d by our "utility"

Including liblustrapi.h is expected, since this is the entry point for the Lustre wrappers, and this header is already installed. 

I did some work several months ago to make lustre_idl.h usable from userspace for lfsck, which works OK except for the use of __u32/__u64 and friends, which needs the "types.h" header to define.

I haven't looked at the other headers (just about to get on a plane) but I think they might be acceptable for low-level Lustre specific applications. That said, the only previous user of these headers is probably lctl, and I'm hesitant to expose them as an "API".

As Nathan wrote, we've tried in the past to do the right thing and create llapi wrappers for code that needs to poke into the Lustre kernel interfaces. This allows things like e.g. fixing the ioctl numbers, changing the data structures used with the kernel, etc. without having to modify the applications that are using these wrappers.

I'm the first one to admit that the llapi_* wrappers do not address a large number of use cases, but that also won't get better if nobody works to improve them. 

I guess a reasonable question at this point is what specifically you are trying to access?  Is it (essentially) trying to link directly into lctl, lfs, etc?  Access to wire protocol structures (that lustre_idl.h should handle), or something else entirely?

> As I said elsewhere somewhere, unless the libcfs, lnet, lustre and utils
> components of lustre know that these are exported via an unambiguous
> mechanism, installing only the minimal subset will be prone to problems.
> A better way is to have them stage the headers and run a validation that
> they are all both self-sufficient and idempotent, meaning that any
> requisite headers are also staged and they are all guarded with duplicate
> inclusion guards.  This can be done with a trivial script.
> 
> I can make this part of the "lustre-devel package" project.  I was trying
> to limit scope by installing everything in sight.  At least for now.
> 
> 
