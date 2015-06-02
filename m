From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 2 Jun 2015 17:29:13 +0000
Subject: [lustre-devel] [HPDD-discuss] [PATCH v1] staging: lustre:
 libcfs: add __user annotation in libcfs_ioctl_data
In-Reply-To: <20150602013115.GB23940@kroah.com>
References: <1432615204-4062-1-git-send-email-ddecotig@gmail.com>
	<20150531022744.GA31012@kroah.com>
	<CAG88wWYSZvS+NByVH3APY-nyF+Di6q_EJPMMXZg9yY4f8rVGHw@mail.gmail.com>
	<20150602013115.GB23940@kroah.com>
Message-ID: <6de5257ecd664c898c9108490e989a88@EXCHCS34.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>>On Mon, Jun 01, 2015 at 12:21:30PM -0700, David Decotigny wrote:
>> Thanks for reviewing.
>> 
>> The 2 struct members were not marked as __user, which this patch does
>> here. This was causing warnings with copy from/to user (see commit
>> description). This patch also propagates the annotation to the couple
>> of functions that are using those members.
>
>Lustre's structures are a total mess of kernel and user pointers and
>trying to properly mark them as which they are supposed to be at what
>point in time is a very difficult task.  People keep trying and get it
>wrong, so I suggest just leaving this alone until the developers unwind
>the structure mess as that will be necessary for this code to get merged
>into the main part of the kernel.

Greg is right. The earlier patch set I sent out for the LNet headers
address this issue for the LNet layer. I also having patches coming that
fix libcfs ioctl handling as well. I see Shuey's patches made it in first so
I'm going to have to rebase. I will send out the new patch sets later today.
This will be v3 of the patch set.
