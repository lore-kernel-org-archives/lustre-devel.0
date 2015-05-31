From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 31 May 2015 11:26:31 +0900
Subject: [lustre-devel] [PATCH] staging: lustre: osc: clean up
 whitespace and align function parameters
In-Reply-To: <1432320647-14543-1-git-send-email-hannac@iu.edu>
References: <1432320647-14543-1-git-send-email-hannac@iu.edu>
Message-ID: <20150531022631.GA30988@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, May 22, 2015 at 02:50:47PM -0400, Chris Hanna wrote:
> Minor changes to remove excessive whitespace and improve
> readability of functions.
> 
> Signed-off-by: Chris Hanna <hannac@iu.edu>
> ---
>  drivers/staging/lustre/lustre/osc/lproc_osc.c   |   56 +++---
>  drivers/staging/lustre/lustre/osc/osc_cache.c   |  112 ++++++------
>  drivers/staging/lustre/lustre/osc/osc_io.c      |  116 +++++++-------
>  drivers/staging/lustre/lustre/osc/osc_lock.c    |  134 ++++++++--------
>  drivers/staging/lustre/lustre/osc/osc_object.c  |   18 +-
>  drivers/staging/lustre/lustre/osc/osc_page.c    |   44 +++---
>  drivers/staging/lustre/lustre/osc/osc_quota.c   |   14 +-
>  drivers/staging/lustre/lustre/osc/osc_request.c |  205 +++++++++++------------
>  8 files changed, 349 insertions(+), 350 deletions(-)

Doesn't apply to my tree :(
