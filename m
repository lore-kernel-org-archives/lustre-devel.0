From: Oleg Drokin <green@whamcloud.com>
Date: Fri, 7 Oct 2011 06:29:12 -0400
Subject: [Lustre-devel] Wide striping
In-Reply-To: <1317859015.15874.2.camel@obelisk.thedillows.org>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<4E8BA3EE.6060300@whamcloud.com>
	<73AED5C780AE05478241DB067651A92102378850@XYUS-EX22.xyus.xyratex.com>
	<4E8CB381.40805@whamcloud.com>
	<9CC6473C-DFE9-4FF4-9AA5-E7AB97D2987D@whamcloud.com>
	<1317859015.15874.2.camel@obelisk.thedillows.org>
Message-ID: <2044C4C7-7F27-4524-B552-CB339A5B14CF@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Oct 5, 2011, at 7:56 PM, David Dillow wrote:
>> Another problems I see here are similar to create on write.
>> Say if we delete a file, do we purge this mapping table too? and then
>> when stale client comes we recreate an orphan object?
>> Or we don't purge the table and let it grow indefinitely using more
>> and more space and eventually slowing down lookups?
>> Or do we purge really old objects from it only, what triggers it, what
>> failure scenarios are there for this process?
>> How do we recover from disasters that happened to this table?
> Wouldn't the online lfsck work being done for OpenSFS catch and correct
> these types of problems?

It probably would, once the online lfsck is implemented.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
