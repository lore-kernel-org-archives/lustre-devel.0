From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Date: Thu, 17 Nov 2011 16:08:39 +0400
Subject: [Lustre-devel] lustre-devel  packaging - LU-482
In-Reply-To: <ABDA628E-8DA2-4CB8-BC57-371942B013D5@whamcloud.com>
References: <CAE97569.14B4%bruce_korb@xyratex.com>
	<ABDA628E-8DA2-4CB8-BC57-371942B013D5@whamcloud.com>
Message-ID: <84CBE853-0699-4AF2-B284-798CA99FD4C1@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Nov 17, 2011, at 05:35, Andreas Dilger wrote:

> On 2011-11-16, at 14:22, Bruce Korb <bruce_korb@xyratex.com> wrote:
>> 
>> I did do a little more due diligence:
>> 
>> On 11/15/11 7:22 AM, Bruce Korb wrote:
>>>> My main question would be - do you _need_ to have access to all of the
>>>> headers that you included, or did you simply include all of the headers
>>>> because that was the easiest thing to do?  Doing a simple check on the
>>>> current master tree, it appears you just copied all of the headers in
>>>> libcfs/include, lnet/include, and lustre/include (which total 186 files).
>>> 
>>> Lets assume I did a minimal approach and only included the necessary
>> 
>> libcfs/libcfsutil.h
>> lnet/lnetctl.h
>> lustre/liblustreapi.h
>> lustre/lustre_idl.h
>> test.h
>> utils/obdctl.h
>> 
>> These are the headers directly #include-d by our "utility"
> 
> Including liblustrapi.h is expected, since this is the entry point for the Lustre wrappers, and this header is already installed. 
> 
> I did some work several months ago to make lustre_idl.h usable from userspace for lfsck, which works OK except for the use of __u32/__u64 and friends, which needs the "types.h" header to define.
that should be done via libcfs.h i think ?
