From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 15 Dec 2015 17:10:39 +0000
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet
	clean up code and API
In-Reply-To: <20151202125440.GS18797@mwanda>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-22-git-send-email-jsimmons@infradead.org>
	<20151202125440.GS18797@mwanda>
Message-ID: <05bc05cb164b4d249f74683aef9c9d72@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Actually we're going to have to redo so much code that it's not worth it
>for me to review the rest of these patches.  

Sorry I didn't get back to you sooner but I was on vacation.  Thanks for 
reviewing this work. Especially since this is the first major bug fixing merge
for the lustre client which means a lot of pain involved to iron out how to
do this. I have been pondering if pushing bug fixes before style cleanups
is the right thing to do. I pushed a bunch of bug fixes earlier and none got
merged which either means Greg is just backed up and hasn't the time to
merge them or  style issues are higher priority. Assuming these bug fixes are
in scope of the staging tree. Should I continue to push this work first?
Well either way I should update this patch series so it ready to merge at some
point.

>Please just look over everything again:
>
> BAD:	return -1;
>GOOD:	return -EINVAL;
>
> BAD:  failed0:
>GOOD:  free_something:
>
> BAD:	if (rc != 0)
>GOOD:	if (rc)
>
>Do one thing per patch.
>Do not introduce a bug and then fix it in a later patch.
>Check ioc_len more carefully.
>Don't make the code look ugly just to please checkpatch.pl.
>Do error handling not success handling.
>Try to avoid indenting a far to the right.

Okay. Will start to do the patch cleanup.
