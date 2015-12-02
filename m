From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 15:59:45 +0300
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet
	clean up code and API
In-Reply-To: <1448062576-23757-22-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-22-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202125440.GS18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Actually we're going to have to redo so much code that it's not worth it
for me to review the rest of these patches.  Please just look over
everything again:

 BAD:	return -1;
GOOD:	return -EINVAL;

 BAD:  failed0:
GOOD:  free_something:

 BAD:	if (rc != 0)
GOOD:	if (rc)

Do one thing per patch.
Do not introduce a bug and then fix it in a later patch.
Check ioc_len more carefully.
Don't make the code look ugly just to please checkpatch.pl.
Do error handling not success handling.
Try to avoid indenting a far to the right.


regards,
dan carpenter
