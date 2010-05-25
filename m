From: ankit sharma <ankit1984.cool@gmail.com>
Date: Tue, 25 May 2010 23:37:38 +0530
Subject: [Lustre-devel] LNET:where in the code dose the file obeject's
	private data gets filled up.
Message-ID: <AANLkTikhDg6RYGCmi0jmwCNerJtc5Y_7oqxkpaq7YhFV@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,
        I am new to Lustre code. So i am sorry if my question is trivial or
silly.

My question:

On line number 116 of the file lnet/lnet/router_proc.c
variable ver_p is getting set from the proc file object's private data.

Can any one tell me which part of the lustre code dose this file object
private data
gets initialized / set .

conceptually in can imagine it should (correct me if I am worng) be set in
open call of the file ( /proc/sys/lnet/routers )

BUT I cant locate the Lustre code that dose that(sets the private data of
file object).






code snippet form lnet/lnet/router_proc.c

int LL_PROC_PROTO(proc_lnet_routes)
{
        int        rc     = 0;
        char      *tmpstr;
        char      *s;
        const int  tmpsiz = 256;
        int        len;
        int       *ver_p  = (unsigned int *)(&filp->private_data);

        DECLARE_LL_PROC_PPOS_DECL;

        LASSERT (!write);

        if (*lenp == 0)
                return 0;

        LIBCFS_ALLOC(tmpstr, tmpsiz);
        if (tmpstr == NULL)
                return -ENOMEM;

        s = tmpstr; /* points to current position in tmpstr[] */

        if (*ppos == 0) {
                s += snprintf(s, tmpstr + tmpsiz - s, "Routing %s\n",
                              the_lnet.ln_routing ? "enabled" : "disabled");
                LASSERT (tmpstr + tmpsiz - s > 0);

                s += snprintf(s, tmpstr + tmpsiz - s, "%-8s %4s %7s %s\n",
                              "net", "hops", "state", "router");
                LASSERT (tmpstr + tmpsiz - s > 0);

                LNET_LOCK();
                *ver_p = (unsigned int)the_lnet.ln_remote_nets_version;
                LNET_UNLOCK();

} else {
                struct list_head  *n;
                struct list_head  *r;
                lnet_route_t      *route = NULL;
                lnet_remotenet_t  *rnet  = NULL;
                int                skip  = *ppos - 1;

                LNET_LOCK();

                if (*ver_p != (unsigned int)the_lnet.ln_remote_nets_version)
{
                        LNET_UNLOCK();
                        LIBCFS_FREE(tmpstr, tmpsiz);
                        return -ESTALE;
                }

                n = the_lnet.ln_remote_nets.next;
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100525/7af34465/attachment.htm>
