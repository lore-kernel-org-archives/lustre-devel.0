From: Amir Shehata <amir.shehata.whamcloud@gmail.com>
Date: Tue, 11 Sep 2018 11:31:00 -0700
Subject: [lustre-devel] [PATCH 11/34] lnet: pass tun to
 lnet_startup_lndni, instead of full conf
In-Reply-To: <153628137168.8267.1167942220741712684.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137168.8267.1167942220741712684.stgit@noble>
Message-ID: <CAAqp6i0McsmGQznjoNisaJNyLFe=Xsa-iAJ9cJsUUNAQpW_Yww@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This block logic that was removed from lnet_startup_lndni() is done in the
LND. Each LND has its own defaults. As an example look at
kiblnd_tunables_setup() and ksocknal_startup().
These tunables are LND specific and have different values per LND. So
instead of configuring it in the common LNet function and then it gets
overwritten again the LND. We let the LND take care of initializing to the
default values that they use for that LND, if they haven't already been set
by the user.
Note currently dynamic configuration of these parameters work only for the
o2iblnd. Socklnd and gnilnd appear to not make use of the dynamic ability.
I'll create an LU ticket to add the ability to dynamically set these values
to the socklnd.
The tunables are divided into two parts, a common set of tunables that are
common to all the LND (although each LND could have different default
values), and a specific set of LND tunables which pertain to a specific
LND, again that's only used by the o2iblnd at the moment.

On Thu, 6 Sep 2018 at 18:00, NeilBrown <neilb@suse.com> wrote:

> I don't understand parts of this change.
> Particularly the removal for
>        /* If given some LND tunable parameters, parse those now to
>         * override the values in the NI structure. */
>
> isn't clear to me.
>
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/api-ni.c |   41
> ++++++++---------------------
>  1 file changed, 12 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c
> b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 6e0b8310574d..53ecfd700db3 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -1240,10 +1240,8 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
>  }
>
>  static int
> -lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data
> *conf)
> +lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
>  {
> -       struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
> -       struct lnet_lnd_tunables *tun = NULL;
>         int rc = -EINVAL;
>         int lnd_type;
>         struct lnet_lnd *lnd;
> @@ -1296,36 +1294,12 @@ lnet_startup_lndni(struct lnet_ni *ni, struct
> lnet_ioctl_config_data *conf)
>
>         ni->ni_net->net_lnd = lnd;
>
> -       if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf)) {
> -               lnd_tunables = (struct lnet_ioctl_config_lnd_tunables
> *)conf->cfg_bulk;
> -               tun = &lnd_tunables->lt_tun;
> -       }
> -
>         if (tun) {
>                 memcpy(&ni->ni_lnd_tunables, tun,
>                        sizeof(*tun));
>                 ni->ni_lnd_tunables_set = true;
>         }
>
> -       /*
> -        * If given some LND tunable parameters, parse those now to
> -        * override the values in the NI structure.
> -        */
> -       if (conf) {
> -               if (conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0)
> -                       ni->ni_net->net_tunables.lct_peer_rtr_credits =
> -
>  conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
> -               if (conf->cfg_config_u.cfg_net.net_peer_timeout >= 0)
> -                       ni->ni_net->net_tunables.lct_peer_timeout =
> -
>  conf->cfg_config_u.cfg_net.net_peer_timeout;
> -               if (conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
> -                       ni->ni_net->net_tunables.lct_peer_tx_credits =
> -
>  conf->cfg_config_u.cfg_net.net_peer_tx_credits;
> -               if (conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0)
> -                       ni->ni_net->net_tunables.lct_max_tx_credits =
> -
>  conf->cfg_config_u.cfg_net.net_max_tx_credits;
> -       }
> -
>         rc = lnd->lnd_startup(ni);
>
>         mutex_unlock(&the_lnet.ln_lnd_mutex);
> @@ -1861,9 +1835,13 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct
> lnet_ioctl_config_data *conf)
>         struct list_head net_head;
>         struct lnet_remotenet *rnet;
>         int rc;
> +       struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
>
>         INIT_LIST_HEAD(&net_head);
>
> +       if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
> +               lnd_tunables = (struct lnet_ioctl_config_lnd_tunables
> *)conf->cfg_bulk;
> +
>         /* Create a net/ni structures for the network string */
>         rc = lnet_parse_networks(&net_head, nets);
>         if (rc <= 0)
> @@ -1898,9 +1876,14 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct
> lnet_ioctl_config_data *conf)
>                 goto failed0;
>
>         list_del_init(&net->net_list);
> +       if (lnd_tunables)
> +               memcpy(&net->net_tunables,
> +                      &lnd_tunables->lt_cmn,
> sizeof(lnd_tunables->lt_cmn));
> +
>         ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
> ni_netlist);
> -       rc = lnet_startup_lndni(ni, conf);
> -       if (rc)
> +       rc = lnet_startup_lndni(ni, (lnd_tunables ?
> +                                    &lnd_tunables->lt_tun : NULL));
> +       if (rc < 0)
>                 goto failed1;
>
>         if (ni->ni_net->net_lnd->lnd_accept) {
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180911/e199bf2c/attachment.html>
