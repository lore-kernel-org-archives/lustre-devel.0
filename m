From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Wed, 11 May 2016 01:17:10 +0000
Subject: [lustre-devel] llmount.sh does not use fs-specific paths to the
 ost(s) and mds it mounts
In-Reply-To: <D3579394.14730F%andreas.dilger@intel.com>
References: <5731EAC3.5070207@cea.fr> <5731ECDF.10801@cea.fr>
	<D3579394.14730F%andreas.dilger@intel.com>
Message-ID: <5A0B9E9B-D8D8-4645-B9F6-BBC7EF41F769@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On May 10, 2016, at 3:42 PM, Dilger, Andreas wrote:

> On 2016/05/10, 08:14, "Quentin BOUGET" <quentin.bouget.ocre@cea.fr> wrote:
>> 
>> Hello!
>> 
>> While trying to mount two different lustre filesystems on a local node
>> with the "llmount.sh" script, I noticed that the path to mount mds and
>> ost(s) was computed like this:
>> 
>> eval mntpt=${!var:-${MOUNT%/*}/$facet} # var is not defined by default,
>> so this removes
>>                                                                    #
>> everything after the last '/' of $MOUNT
>> 
>> 
>> The code can be found at test-framework.sh in the function "facet_mntpt"
>> around the line 3226.
>> 
>> 
>> By default MOUNT is initialized like this:
>> 
>> MOUNT=${MOUNT:-/mnt/${FSNAME}} # default: "/mnt/lustre"
>> 
>> 
>> Thus the default mountpoints for mds and ost(s) are "/mnt/mds1" and
>> "/mnt/ost1".
>> Because of that, when trying to do two successive calls to "llmount.sh"
>> with two different values for FSNAME, the second fs to be mounted will
>> unmount the first's mds and ost(s) (paths are identical).
>> 
>> 
>> Is there any reason to truncate the MOUNT variable like this ? Shouldn't
>> the mountpoint path look more like "/mnt/<fsname>-mds1" and
>> "/mnt/<fsname>-ost1"?
> 
> I don't think there is any particular reason it was implemented this way,
> just that it has worked for many years without the need to include the
> fsname into the MDT/OST mount points... :-)
> 
> If you want to expand it to allow exporting multiple filesystems from the
> same MDS/OSS nodes then your suggestion to use $FSNAME-$facet in
> facet_mntpt() is reasonable.  Please submit a patch to verify this is
> working correctly.  There may be some places in the tests that aren't
> using facet_mntpt() yet.

I guess to expand on this, since llmount.sh is primarily a testing
infrastructure and typically only one filesystem at a time is tested,
the more than one mountpoint was never bothering anyone till you
discovered this bit, I guess.

Bye,
    Oleg
