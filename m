From: Roman Storozhenko <romeusmeister@gmail.com>
Date: Sat, 10 Jun 2017 15:01:50 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Replace the
 symbolic file permission mode with the numeric one
In-Reply-To: <78EAE665-9BDD-4EF4-8793-3FC55D565AFB@cray.com>
References: <20170608172541.GA2314@home>
	<78EAE665-9BDD-4EF4-8793-3FC55D565AFB@cray.com>
Message-ID: <20170610120150.GA18030@home>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jun 09, 2017 at 08:13:49PM +0000, Cory Spitz wrote:
> Roman,
> You have ?0007? in the description vs. ?0777? in the patch.
> -Cory
> 
> 
> On 6/8/17, 12:25 PM, "lustre-devel on behalf of Roman Storozhenko" <lustre-devel-bounces at lists.lustre.org on behalf of romeusmeister@gmail.com> wrote:
> 
>     Replaces S_IRWXUGO with 0007. The reason is that symbolic permissions
> 
> 
> +		mode = data->ioc_type != 0 ? data->ioc_type : 0777;
>  
> 

Thanks that you pointed out that error. I have published the second
version of the patch here:
http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2017-June/005727.html
