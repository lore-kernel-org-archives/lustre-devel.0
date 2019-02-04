From: Leonel Ochoa <lochoa@whamcloud.com>
Date: Mon, 4 Feb 2019 18:26:42 +0000
Subject: [lustre-devel] Maloo Unscheduled Maintenance
In-Reply-To: <6DF7A165-B104-4A84-92F3-85770D7D7D7A@ddn.com>
References: <6DF7A165-B104-4A84-92F3-85770D7D7D7A@ddn.com>
Message-ID: <4DCFCF25-8AC4-47B0-9D1F-EB62AEBE0598@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

FINAL UPDATE:
The Maloo server has been running nominally since last week, results data is available going back to Jan 2017, the remaining sub test and test log results from 2016 will be ingested overnight

Lee Ochoa
lochoa at whamcloud.com<mailto:lochoa@whamcloud.com>


From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Leonel Ochoa <lochoa@whamcloud.com>
Date: Thursday, January 31, 2019 at 17:44
To: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] Maloo Unscheduled Maintenance

UPDATE:

At this point we?re all caught up with all sessions that were pending. If you notice a session missing between 1/19 and now, or a missing gerrit score please feel free to reach out and we can work on troubleshooting missing results/scores.
At this point the only missing data is sub tests and test logs EARLIER than 1/19, this will populate slowly and I?ll announce once they?re all ingested.


Lee Ochoa
lochoa at whamcloud.com<mailto:lochoa@whamcloud.com>


From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Leonel Ochoa <lochoa@whamcloud.com>
Date: Wednesday, January 30, 2019 at 21:49
To: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] Maloo Unscheduled Maintenance

UPDATE:

Maloo is back up?but not fully restored yet. For the time being you?ll notice the following things:

  1.  Test queue pages DO show accurate state of ongoing tests in Autotest
  2.  The main test session page is missing results from 1/19 ? 1/30, these results will start getting ingested from oldest to newest, please be patient and all results will eventually show up
  3.  For test sessions EARLIER than 1/19, sub test and test log pages are missing and will slowly populate, also from oldest to newest, also please be patient
I?ll be sending periodic updates as we fill in the missing data

Lee Ochoa
lochoa at whamcloud.com<mailto:lochoa@whamcloud.com>


From: Leonel Ochoa <lochoa@whamcloud.com>
Date: Tuesday, January 29, 2019 at 14:12
To: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Maloo Unscheduled Maintenance

NOTICE TO ALL MALOO USERS

The Maloo web server has been down since yesterday 1/28 due to unscheduled maintenance, at present we expect the downtime to last all of today 1/29 and possibly tomorrow 1/30 as well. Once service has been restored we?ll post a notification to this mailing list.

Gerrit can still receive patches and Autotest will continue to run test sessions while Maloo remains offline, once the server is back up all pending results and gerrit +/- notifications (from Maloo) will be sent for all completed tests.

Thank you for your patience.

Lee Ochoa
lochoa at whamcloud.com<mailto:lochoa@whamcloud.com>


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190204/2402664d/attachment-0001.html>
