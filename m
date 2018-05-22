From: Joe Perches <joe@perches.com>
Date: Tue, 22 May 2018 12:36:28 -0700
Subject: [lustre-devel] [PATCH] checkpatch: Fix macro argument precedence
 test
In-Reply-To: <20180522133439.12338-1-brnkv.i1@gmail.com>
References: <20180522133439.12338-1-brnkv.i1@gmail.com>
Message-ID: <5dd900e9197febc1995604bb33c23c136d8b33ce.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@canonical.com>, LKML <linux-kernel@vger.kernel.org>
Cc: Ivan Bornyakov <brnkv.i1@gmail.com>, lustre-devel@lists.lustre.org

checkpatch's macro argument precedence test is broken so fix it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index baddac9379f0..68879aa65cfd 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5041,7 +5041,7 @@ sub process {
 				$tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
 				$tmp_stmt =~ s/\#+\s*$arg\b//g;
 				$tmp_stmt =~ s/\b$arg\s*\#\#//g;
-				my $use_cnt = $tmp_stmt =~ s/\b$arg\b//g;
+				my $use_cnt = () = $tmp_stmt =~ /\b$arg\b/g;
 				if ($use_cnt > 1) {
 					CHK("MACRO_ARG_REUSE",
 					    "Macro argument reuse '$arg' - possible side-effects?\n" . "$herectx");
