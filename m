From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 4 Dec 2017 08:20:29 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Fix sparse,
 using plain integer as NULL pointer in lov_object_fiemap()
In-Reply-To: <e5107da2-a834-e1fd-03b8-01f60e4e19f4@mail.ru>
References: <e5107da2-a834-e1fd-03b8-01f60e4e19f4@mail.ru>
Message-ID: <7A48E652-421B-464B-AD2A-C3D5613B48E5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrii Vladyka <tulup@mail.ru>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> On Nov 30, 2017, at 11:30, Andrii Vladyka <tulup@mail.ru> wrote:
> 
> Change 0 to NULL in lov_object_fiemap() in order to fix warning produced by sparse
> 
> Signed-off-by: Andrii Vladyka <tulup@mail.ru>

Patches should be inline rather than in an attachment.

That said, the patch looks correct, so you can add:

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
