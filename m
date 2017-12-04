From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 4 Dec 2017 11:35:00 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: check result of
 register_shrinker
In-Reply-To: <985AF256-3022-45FB-BFCF-1E2B0F622AA8@intel.com>
References: <20171202184046.4338-1-akaraliou.dev@gmail.com>
 <985AF256-3022-45FB-BFCF-1E2B0F622AA8@intel.com>
Message-ID: <20171204083500.hqpc3f5arnti46pd@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Dec 03, 2017 at 12:47:03AM +0000, Dilger, Andreas wrote:
> The preferred way to handle this would be:
> 
> 	rc = ldlm_pools_thread_start();
> 	if (rc)
> 		goto out;
> 
> 	rc = register_shrinker(&ldlm_pools_cli_shrinker);
> 	if (rc)
> 		goto out_pools;
> 
> 	return 0;
> 
> out_pools:
> 	ldlm_pools_thread_stop();
> out:
> 	goto out;
> }

I so badly hate "out" as a label name...  But yours made me laugh.

regards,
dan carpenter
