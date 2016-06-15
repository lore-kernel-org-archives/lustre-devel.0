From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Wed, 15 Jun 2016 05:11:29 +0200
Subject: [lustre-devel] [PATCH 2/5] staging/lustre: Replace sun.com
 GPLv2 URL with gnu.org one
Message-ID: <4da9baaf-6369-0eb0-850b-87c827d94c3b@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Linux Driver Project Developer List <driverdev-devel@linuxdriverproject.org>, "<lustre-devel@lists.lustre.org> Development" <lustre-devel@lists.lustre.org>

Oleg Drokin wrote:

> http://www.sun.com/software/products/lustre/docs/GPLv2.pdf is no
> longer around, so replace it with (hopefully more permanent)
> http://http://www.gnu.org/licenses/gpl-2.0.html
        ^^^^^^

> [...]
> drivers/staging/lustre/lustre/ptlrpc/service.c                        | 2 +-
>  drivers/staging/lustre/lustre/ptlrpc/wiretest.c                       | 2 +-
>  240 files changed, 240 insertions(+), 240 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
> index c673dfc..2ab5002 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
> @@ -15,7 +15,7 @@
>   *
>   * You should have received a copy of the GNU General Public License
>   * version 2 along with this program; If not, see
> - * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
> + * http://http://www.gnu.org/licenses/gpl-2.0.html
            ^^^^^^^

"http://" was repeated.

And "http://www.gnu.org/licenses/" is preferred

Thank you.
