From: Bruce Korb <bruce_korb@xyratex.com>
Date: Tue, 07 Aug 2012 14:00:57 -0700
Subject: [Lustre-devel] [lustre-devel]  merges to b2_<x>
In-Reply-To: <E6EEE694-681F-4414-A41C-AD634C17800B@whamcloud.com>
Message-ID: <CC46CE84.5D03%bruce_korb@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

On 8/7/12 12:45 PM, Andreas Dilger wrote:
>> Another way to do this would be to use the same Change-Id field for the
>> backported patch. One could grep for the Change-Id in the commit logs
>> relatively easily, although I'm not sure how the review system would
>> handle this.
>
>Using the same Change-Id on two different branches causes heartburn for
>Gerrit, unfortunately.  This has happened by accident a few times, when a
>series of patches were merged into a development branch and then
>accidentally pushed to Gerrit.  It thinks that these previously-landed
>patches are all "in progress" again, and causes every later patch on the
>original branch (usually master) to claim them as open dependencies.

Maybe you could find some script maestro who could auto-insert this
magic tag at the same time the original Change-Id gets inserted?
Commit-Id: anyone?
