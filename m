From: =?utf-8?B?0JHQu9Cw0LPQvtC00LDRgNC10L3QutC+INCQ0YDRgtGR0Lw=?= <artem.blagodarenko@gmail.com>
Date: Thu, 8 Feb 2018 12:42:39 +0300
Subject: [lustre-devel] testing lustre
In-Reply-To: <87po5gmqph.fsf@notabene.neil.brown.name>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
 <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
 <87po5gmqph.fsf@notabene.neil.brown.name>
Message-ID: <94546355-FD93-4B50-AC98-4AB38EDC9BF0@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello NeilBrown,

Symbol ?:? is added to name for targets which have never been registered. tunefs and mount use this symbol to
set LDD_F_VIRGIN flag in ldd.

Here is code from lustre/utils/mkfs_lustre.c (executed in tunefs)

 /* svname of the form lustre:OST1234 means never registered */
        ret = strlen(ldd->ldd_svname);
        if (ldd->ldd_svname[ret - 8] == ':') {
                ldd->ldd_svname[ret - 8] = '-';
                ldd->ldd_flags |= LDD_F_VIRGIN;

And 

lustre/utils/mount_lustre.c

/* svname of the form lustre:OST1234 means never registered */
        rc = strlen(ldd->ldd_svname);
        if (strcmp(ldd->ldd_svname, "MGS") != 0) {
                if (rc < 8) {
                        fprintf(stderr, "%s: invalid name '%s'\n",
                                progname, ldd->ldd_svname);
                        return EINVAL;
                } else if (ldd->ldd_svname[rc - 8] == ':') {
                        ldd->ldd_svname[rc - 8] = '-';
                        ldd->ldd_flags |= LDD_F_VIRGIN;

So I believe the test expects freshly created target.

Best regards,
Artem Blagodarenko.

> On 8 Feb 2018, at 00:31, NeilBrown <neilb@suse.com> wrote:
> 
> 
> Hi,
> I've set up a little virtual cluster to run the sanity tests.
> One problem I have is that the test harness expects that after it
> creates a filesystem, the label (reported by e2label) will
> spontaneously change from e.g. "lustre:MDT-0000" to "lustre-MDT-0000"
> and that doesn't happen for me.
> If I go and change the label manually while the test is waiting,
> then the test continues and appears to run correctly.
> 
> Can anyone tell me what this name change in meant to indicate, when
> where in the code it is expected to happen?
> 
> Thanks,
> NeilBrown
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
