From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 30 May 2018 13:05:29 +0300
Subject: [lustre-devel] [PATCH v2 01/25] staging: lustre: libcfs:
 restore UMP handling
In-Reply-To: <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20180530100529.54jlkfx2q52d7o2a@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:41AM -0400, James Simmons wrote:
> @@ -208,20 +222,52 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  void cfs_cpu_fini(void);
>  
>  #else /* !CONFIG_SMP */
> -struct cfs_cpt_table;
> -#define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
>  
> -static inline cpumask_var_t *
> -cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
> +static inline void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
>  {
> -	return NULL;
> +	kfree(cptab);
>  }

This should free cptab->ctb_cpumask?

regards,
dan carpenter
