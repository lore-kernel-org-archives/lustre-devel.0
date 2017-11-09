From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 9 Nov 2017 10:06:10 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Replaces 'uint32_t'
 with '__u32' and 'uint64_t' with '__u64'.
In-Reply-To: <20171103123658.GA21148@home>
References: <20171029175839.GA19864@home> <20171103114618.GA11059@kroah.com>
 <20171103123658.GA21148@home>
Message-ID: <D397582D-545E-4C40-8A51-1F208F5E1883@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 3, 2017, at 06:36, Roman Storozhenko <romeusmeister@gmail.com> wrote:
> 
> On Fri, Nov 03, 2017 at 12:46:18PM +0100, Greg Kroah-Hartman wrote:
>> On Sun, Oct 29, 2017 at 08:58:39PM +0300, Roman Storozhenko wrote:
>>> There are two reasons for that:
>>> 1) As Linus Torvalds said we should use kernel types:
>>> http://lkml.iu.edu/hypermail//linux/kernel/1506.0/00160.html
>>> 
>>> 2) There are only few places in the lustre codebase that use such types.
>>> In the most cases it uses '__u32' and '__u64'.
>> 
>>> drivers/staging/lustre/lustre/include/lustre_sec.h |  4 ++--
>>> drivers/staging/lustre/lustre/llite/vvp_dev.c      |  2 +-
>>> drivers/staging/lustre/lustre/lov/lov_internal.h   | 12 ++++++------
>>> drivers/staging/lustre/lustre/osc/osc_internal.h   |  6 +++---
>>> 4 files changed, 12 insertions(+), 12 deletions(-)
>> 
>> The __ types are only needed for when you cross the user/kernel boundry.
>> Otherwise just use the "normal" types of u32 and u64.
>> 
>> Do the changes you made here all cross that boundry?  If not, please fix
>> this up.
> 
> Thanks, Greg.
> 
> I have checked lustre repository and it seems that changed ".h" files aren't used in client code. But I realise that I could be mistaken. That why I want to ask lustre guys: am I right?

Sorry for not getting back to you sooner, I was traveling.

I'm not sure what you mean by the .h files aren't used in client code?
I checked all of the headers, and all of the structures that were changed,
and they all looked to be in use.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
