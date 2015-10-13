From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:23:54 +0200
Subject: [lustre-devel] [PATCH 4/7] staging: lustre: echo_client.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <fdfe519b4b8143173b30e6d6071a2f6a212931ea.1444774232.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces container_of0 by container_of. The only difference between
the two implementations is that container_of0 tries to evade
type casting if the pointer is erroneous or null. The use of
container_of is encouraged to bring lustre one step closer to
community standards.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index ef9cb31..1e9a57f 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -103,7 +103,7 @@ static int echo_client_cleanup(struct obd_device *obddev);
  */
 static inline struct echo_device *cl2echo_dev(const struct cl_device *dev)
 {
-	return container_of0(dev, struct echo_device, ed_cl);
+	return container_of(dev, struct echo_device, ed_cl);
 }
 
 static inline struct cl_device *echo_dev2cl(struct echo_device *d)
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
