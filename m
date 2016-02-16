From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:41 -0500
Subject: [lustre-devel] [PATCH 09/45] staging/lustre: Remove server code
	from class_get_type()
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

class_get_type has some references to various server modules
that could not exist on the server, so get rid of them.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/genops.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 5665655..1cb68df 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -113,15 +113,6 @@ static struct obd_type *class_get_type(const char *name)
 	if (!type) {
 		const char *modname = name;
 
-		if (strcmp(modname, "obdfilter") == 0)
-			modname = "ofd";
-
-		if (strcmp(modname, LUSTRE_LWP_NAME) == 0)
-			modname = LUSTRE_OSP_NAME;
-
-		if (!strncmp(modname, LUSTRE_MDS_NAME, strlen(LUSTRE_MDS_NAME)))
-			modname = LUSTRE_MDT_NAME;
-
 		if (!request_module("%s", modname)) {
 			CDEBUG(D_INFO, "Loaded module '%s'\n", modname);
 			type = class_search_type(name);
-- 
2.1.0
