From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Thu, 23 Mar 2017 17:03:36 +0300
Subject: [lustre-devel] [PATCH 5/6] Throttle the outgoing requests
 according to tau
In-Reply-To: <613cd7339035952e7f4dce3aa9f3db9e8bb52c92.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
	<613cd7339035952e7f4dce3aa9f3db9e8bb52c92.1490122510.git.yanli@ascar.io>
Message-ID: <CAJ2e-W0p2Mhri_Pzf8q1d=8r0CuxkStMcjZYE7Q7azbsUkVbgA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I dislike a sleep in this code.
I think you should use req->rq_sent time to have a some delay, as way as
osc redo code does.
ptlrpc_check_set()
..

                /* delayed send - skip */

                if (req->rq_phase == RQ_PHASE_NEW && req->rq_sent)

                        continue;



On Tue, Mar 21, 2017 at 10:43 PM, Yan Li <yanli@ascar.io> wrote:

> Signed-off-by: Yan Li <yanli@ascar.io>
> ---
>  lustre/osc/osc_cache.c    |  3 +++
>  lustre/osc/osc_internal.h | 66 ++++++++++++++++++++++++++++++
> +++++++++++++++++
>  2 files changed, 69 insertions(+)
>
> diff --git a/lustre/osc/osc_cache.c b/lustre/osc/osc_cache.c
> index 236263c..2f9d4e1 100644
> --- a/lustre/osc/osc_cache.c
> +++ b/lustre/osc/osc_cache.c
> @@ -2316,6 +2316,9 @@ static int osc_io_unplug0(const struct lu_env *env,
> struct client_obd *cli,
>         } else {
>                 CDEBUG(D_CACHE, "Queue writeback work for client %p.\n",
> cli);
>                 LASSERT(cli->cl_writeback_work != NULL);
> +#ifdef ENABLE_RLQOS
> +               qos_throttle(&cli->qos);
> +#endif
>                 rc = ptlrpcd_queue_work(cli->cl_writeback_work);
>         }
>         return rc;
> diff --git a/lustre/osc/osc_internal.h b/lustre/osc/osc_internal.h
> index 06c21b3..d31d5ba 100644
> --- a/lustre/osc/osc_internal.h
> +++ b/lustre/osc/osc_internal.h
> @@ -245,4 +245,70 @@ extern unsigned long osc_cache_shrink_count(struct
> shrinker *sk,
>  extern unsigned long osc_cache_shrink_scan(struct shrinker *sk,
>                                            struct shrink_control *sc);
>
> +#ifdef ENABLE_RLQOS
> +static inline void qos_throttle(struct qos_data_t *qos)
> +{
> +       struct timeval now;
> +       long           usec_since_last_rpc;
> +       long           need_sleep_usec = 0;
> +
> +       spin_lock(&qos->lock);
> +       if (0 == qos->min_usec_between_rpcs)
> +               goto out;
> +
> +       do_gettimeofday(&now);
> +       usec_since_last_rpc = cfs_timeval_sub(&now, &qos->last_rpc_time,
> NULL);
> +       if (usec_since_last_rpc < 0) {
> +               usec_since_last_rpc = 0;
> +       }
> +       if (usec_since_last_rpc < qos->min_usec_between_rpcs) {
> +               need_sleep_usec = qos->min_usec_between_rpcs -
> usec_since_last_rpc;
> +       }
> +       qos->last_rpc_time = now;
> +out:
> +       spin_unlock(&qos->lock);
> +       if (0 == need_sleep_usec) {
> +               return;
> +       }
> +
> +       /* About timer ranges:
> +          Ref: https://urldefense.proofpoint.com/v2/url?u=https-3A__www.
> kernel.org_doc_Documentation_timers_timers-2Dhowto.txt&d=
> DwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa
> 3P4AXaemlM6Lg&m=w0oijGmz2ea38--CHGZq4fPu44dwEldJr2BDVZcBR2U&
> s=jN5WjVQ8jELL9iEXADWoal4-Yo76FIU3VVDcdN3zsC4&e=  */
> +       if (need_sleep_usec < 1000) {
> +               udelay(need_sleep_usec);
> +       } else if (need_sleep_usec < 20000) {
> +               usleep_range(need_sleep_usec - 1, need_sleep_usec);
> +       } else {
> +               msleep(need_sleep_usec / 1000);
> +       }
> +}
> +#endif /* ENABLE_RLQOS */
> +
> +/* You must call LPROCFS_CLIMP_CHECK() on the obd device before and
> + * LPROCFS_CLIMP_EXIT() after calling this function. They are not called
> inside
> + * this function, because they may return an error code.
> + */
> +static inline void set_max_rpcs_in_flight(int val, struct client_obd *cli)
> +{
> +       int adding, added, req_count;
> +
> +       adding = val - cli->cl_max_rpcs_in_flight;
> +       req_count = atomic_read(&osc_pool_req_count);
> +       if (adding > 0 && req_count < osc_reqpool_maxreqcount) {
> +               /*
> +                * There might be some race which will cause over-limit
> +                * allocation, but it is fine.
> +                */
> +               if (req_count + adding > osc_reqpool_maxreqcount)
> +                       adding = osc_reqpool_maxreqcount - req_count;
> +
> +               added = osc_rq_pool->prp_populate(osc_rq_pool, adding);
> +               atomic_add(added, &osc_pool_req_count);
> +       }
> +
> +       spin_lock(&cli->cl_loi_list_lock);
> +       cli->cl_max_rpcs_in_flight = val;
> +       client_adjust_max_dirty(cli);
> +       spin_unlock(&cli->cl_loi_list_lock);
> +}
> +
>  #endif /* OSC_INTERNAL_H */
> --
> 1.8.3.1
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.
> lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=DwICAg&c=IGDlg0lD0b-
> nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=w0oijGmz2ea38-
> -CHGZq4fPu44dwEldJr2BDVZcBR2U&s=ppAA2u9phKTaqwpnFsNVQGtqbG3xF6
> tk4_Q9mVL_lGk&e=
>



-- 
Alexey Lyashkov *?* Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com
www.lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170323/f9d9ab00/attachment.htm>
