From: Bernd Schubert <bs_lists@aakef.fastmail.fm>
Date: Wed, 20 May 2009 19:39:16 +0200
Subject: [Lustre-devel] cvs question
Message-ID: <200905201939.16472.bs_lists@aakef.fastmail.fm>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello, 

I just want to backport the patches of bug#18414 and there is merge conflict,
something is missing. So I want to check with cvs what that is, but the
result is a bit weird (on b1_6):

cvs annotate lnet/libcfs/watchdog.c

1.2          (eeb      09-Dec-04): static void lcw_cb(unsigned long data)
1.2          (eeb      09-Dec-04): {
1.2          (eeb      09-Dec-04):         struct lc_watchdog *lcw = (struct 
lc_watchdog *)data;
1.2          (eeb      09-Dec-04):
1.2          (eeb      09-Dec-04):         ENTRY;
1.2          (eeb      09-Dec-04):
1.2          (eeb      09-Dec-04):         if (lcw->lcw_state != 
LC_WATCHDOG_ENABLED) {
1.2          (eeb      09-Dec-04):                 EXIT;
1.2          (eeb      09-Dec-04):                 return;
1.2          (eeb      09-Dec-04):         }
1.2          (eeb      09-Dec-04):
1.2          (eeb      09-Dec-04):         lcw->lcw_state = 
LC_WATCHDOG_EXPIRED;
1.2          (eeb      09-Dec-04):
1.6          (nathan   10-Feb-07):         /* NB this warning should appear on 
the console, but may not get into
1.6          (nathan   10-Feb-07):          * the logs since we're running in 
a softirq handler */
1.6          (nathan   10-Feb-07):
1.7          (nathan   26-Feb-07):         CWARN("Watchdog triggered for pid 
%d: it was inactive for %lds\n",
1.7          (nathan   26-Feb-07):               (int)lcw->lcw_pid, 
cfs_duration_sec(lcw->lcw_time));
1.6          (nathan   10-Feb-07):         lcw_dump(lcw);


But this looks different than the file itself:


static void lcw_cb(unsigned long data)
{
        struct lc_watchdog *lcw = (struct lc_watchdog *)data;
        cfs_time_t current_time;
        cfs_duration_t delta_time;
        struct timeval timediff;

        ENTRY;

        if (lcw->lcw_state != LC_WATCHDOG_ENABLED) {
                EXIT;
                return;
        }

        lcw->lcw_state = LC_WATCHDOG_EXPIRED;
        current_time = cfs_time_current();

        delta_time = cfs_time_sub(current_time, lcw->lcw_last_touched);
        cfs_duration_usec(delta_time, &timediff);



So what is going on there? Where does for example

current_time = cfs_time_current();

come from? I'm confused as usual how cvs handles things.


Thanks,
Bernd
