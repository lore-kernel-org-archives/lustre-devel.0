From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 15 Oct 2015 14:38:45 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
In-Reply-To: <20151015111419.GA24704@mwanda>
References: <20151015111419.GA24704@mwanda>
Message-ID: <20151015113845.GQ7289@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Actually this we can't overflow here, it will return -EFAULT if param is
NULL and paramlen is non-zero.  I'll send a patch to clean this up.

regards,
dan carpenter
