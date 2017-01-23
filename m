From: Joe Perches <joe@perches.com>
Date: Mon, 23 Jan 2017 13:01:16 -0800
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: change wire
 protocol typedefs to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485205276.12563.30.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>

On Sat, 2017-01-21 at 19:40 -0500, James Simmons wrote:
> The upstream kernel requires proper structures so
> convert nearly all the LNet wire protocols typedefs in
> the LNet core.

Thanks.

Perhaps s/\bWIRE_ATTR\b/__packed/g one day too
