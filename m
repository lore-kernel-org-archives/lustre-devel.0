From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Tue, 15 Nov 2011 07:43:31 -0800
Subject: [Lustre-devel] [lustre-devel] lustre-devel packaging - LU-482
In-Reply-To: <CAE7B612.1389%bruce_korb@xyratex.com>
References: <CAE7B612.1389%bruce_korb@xyratex.com>
Message-ID: <9C6215E9-C385-44B7-BF35-2A20E85C8967@us.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Nov 15, 2011, at 7:22 AM, "Bruce Korb" <bruce_korb@xyratex.com> wrote:

> Hi Adreas,
> 
> On 11/15/11 1:47 AM, Andreas Dilger wrote:
> 
>> On 2011-11-14, at 7:11 AM, Bruce Korb wrote:
>> My main question would be - do you _need_ to have access to all of the
>> headers that you included, or did you simply include all of the headers
>> because that was the easiest thing to do?  Doing a simple check on the
>> current master tree, it appears you just copied all of the headers in
>> libcfs/include, lnet/include, and lustre/include (which total 186 files).
> 
> 
> Were the private vs. public headers separated in some way, then
> the unwanted exports could be removed.  At the moment, I think
> the assumption has to be that clients of the lustre-devel package
> would have to be friendly clients.  Very friendly.  Right now, we
> have actual clients grubbing around all over the lustre source
> tree in a very unfriendly way.
Actually I thought we were careful to only expose llapi_* functions. So what's doing the grubbing?
