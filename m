From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 1 Feb 2019 15:46:11 +0000
Subject: [lustre-devel] Run acceptance tests on client side only
In-Reply-To: <DM6PR19MB2508057050FAA6F37D7A987BC5900@DM6PR19MB2508.namprd19.prod.outlook.com>
References: <9E0B8A72-3AFF-4141-8E94-28AF402B0CC9@amazon.com>
 <DM6PR19MB2508057050FAA6F37D7A987BC5900@DM6PR19MB2508.namprd19.prod.outlook.com>
Message-ID: <8D2B81B6-81CC-47AE-853B-931906283753@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Patrick,

I?m working with a non-production FS, so I do not care about destructive actions, but you?re right, the acceptance test system is not really designed to be used really differently. Even if you have access to the servers, it requires a lot of tunings to have this working properly.

I wanted to know if I missed something and there was an easy solution, but I will try do this differently.

Thanks

Aur?lien

De : Patrick Farrell <pfarrell@whamcloud.com>
Date : mercredi 30 janvier 2019 ? 20:02
? : "Degremont, Aurelien" <degremoa@amazon.com>, "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Objet : Re: Run acceptance tests on client side only


Aurelien,



We played with this idea some when I was at Cray, and I believe we decided it wasn't worth it.  Many, many tests - maybe a majority - depend on running commands on the server.  Many are intentionally destructive in various ways, and since we don't test them with other data on the file system, some of them are probably *accidentally* destructive as well.



My conclusion then was that the test framework tests (acceptance small included) are not designed to be run A) without server access, or B ) on any kind of production file system.



It would be possible to create a curated client only & non-destructive list, but it would be a lot of work, and it would miss large areas of the test framework.  (Many tests which are primarily client require some manipulation of the server (settings, cache dropping, fail loc...) to work.)



- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Degremont, Aurelien <degremoa@amazon.com>
Sent: Wednesday, January 30, 2019 8:53:12 AM
To: lustre-devel at lists.lustre.org
Subject: [lustre-devel] Run acceptance tests on client side only


Hello



I?m trying to run test suites without having access to servers.

A lot of tests in acc-sm assume that servers are reachable. Is there way to automatically skip these tests?



Does somebody has a smart way to run acc-sm?



Thanks



Aur?lien
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190201/52df7435/attachment-0001.html>
