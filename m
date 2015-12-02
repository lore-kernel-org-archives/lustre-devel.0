From: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>
Date: Wed, 2 Dec 2015 16:20:59 +0300
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet
 clean up code and API
In-Reply-To: <20151202125440.GS18797@mwanda>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-22-git-send-email-jsimmons@infradead.org>
	<20151202125440.GS18797@mwanda>
Message-ID: <CAHtKf-aEa4YvhgvZgAFLuOVbX=bdmC+YQwaAH5p2-qCAS_W8Vg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

On Wed, Dec 2, 2015 at 3:59 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Actually we're going to have to redo so much code that it's not worth it
> for me to review the rest of these patches.  Please just look over
> everything again:
>
>  BAD:   return -1;
> GOOD:   return -EINVAL;
>
>  BAD:  failed0:
> GOOD:  free_something:
>
>  BAD:   if (rc != 0)
> GOOD:   if (rc)

The latest suggestion is not correct,
from http://wiki.lustre.org/Lustre_Coding_Guidelines :
Conditional boolean (if (expr)), scalar (if (val != 0)) and pointer
(if (ptr != NULL)) expressions should be written consistently.

Thanks,

-- 
Alexander Zarochentsev
Seagate Technology, LLC
www.seagate.com
