From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 6 Nov 2015 17:16:56 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: selftest: Move
 extern declarations to headers
In-Reply-To: <20151105203421.GA12506@amitoj-Inspiron-3542>
References: <20151105203421.GA12506@amitoj-Inspiron-3542>
Message-ID: <20151107011656.GA4165@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 06, 2015 at 02:04:21AM +0530, Amitoj Kaur Chawla wrote:
> This patch moves extern declarations to respective header files.
> 
> This patch also removes extern keyword from function declarations
> since functions have the extern specifier by default.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Doesn't apply to my staging-testing branch anymore due to patches send
before yours :(

Please refresh it and resend.

thanks,

greg k-h
