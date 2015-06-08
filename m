From: Joe Perches <joe@perches.com>
Date: Mon, 08 Jun 2015 12:57:49 -0700
Subject: [lustre-devel] [PATCH v4 1/7] staging:lustre: move tcpip
	abstraction
In-Reply-To: <20150608193359.GA1001@kroah.com>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-2-git-send-email-jsimmons@infradead.org>
	<20150608193359.GA1001@kroah.com>
Message-ID: <1433793469.2730.5.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2015-06-08 at 12:33 -0700, Greg Kroah-Hartman wrote:
> Please generate patches in -M format, so I can see the rename properly,
> as it is, this is too messy for me to review.

Adding this to the .gitconfig works too

[diff]
	renames = true

That should probably be mentioned in SubmittingPatches.

Something like:
---
 Documentation/SubmittingPatches | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
index 27e7e5e..d86cf89 100644
--- a/Documentation/SubmittingPatches
+++ b/Documentation/SubmittingPatches
@@ -715,6 +715,13 @@ the top of the kernel source tree and don't use too much horizontal
 space (easily fit in 80 columns, maybe with some indentation).  (git
 generates appropriate diffstats by default.)
 
+Another good thing is to generate shorter patches whenever a file rename
+has been done.  Using "git format-patch -M" does this appropriately.
+Adding a [diff] section as below to .gitconfig can also do this:
+
+       [diff]
+              renames = true
+
 See more details on the proper patch format in the following
 references.
 
