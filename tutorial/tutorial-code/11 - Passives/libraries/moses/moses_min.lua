local daa='1.6.0'local _ba,aba,bba,cba=next,type,select,pcall;local dba,_ca=setmetatable,getmetatable
local aca,bca=table.insert,table.sort;local cca,dca=table.remove,table.concat
local _da,ada,bda=math.randomseed,math.random,math.huge;local cda,dda,__b=math.floor,math.max,math.min;local a_b=rawget
local b_b=table.unpack or unpack;local c_b,d_b=pairs,ipairs;local _ab={}local function aab(bcb,ccb)return bcb>ccb end
local function bab(bcb,ccb)return bcb<ccb end;local function cab(bcb,ccb,dcb)
return(bcb<ccb)and ccb or(bcb>dcb and dcb or bcb)end
local function dab(bcb,ccb)return ccb and true end;local function _bb(bcb)return not bcb end;local function abb(bcb)local ccb=0
for dcb,_db in c_b(bcb)do ccb=ccb+1 end;return ccb end
local function bbb(bcb,ccb,dcb,...)local _db
local adb=dcb or _ab.identity;for bdb,cdb in c_b(bcb)do
if not _db then _db=adb(cdb,...)else local ddb=adb(cdb,...)_db=
ccb(_db,ddb)and _db or ddb end end;return _db end
local function cbb(bcb,ccb,dcb,_db)for i=0,#bcb,ccb do local adb=_ab.slice(bcb,i+1,i+ccb)
if#adb>0 then while
(#adb<ccb and _db)do adb[#adb+1]=_db end;dcb(adb)end end end
local function dbb(bcb,ccb,dcb,_db)
for i=0,#bcb,ccb-1 do local adb=_ab.slice(bcb,i+1,i+ccb)if
#adb>0 and i+1 <#bcb then while(#adb<ccb and _db)do adb[#adb+1]=_db end
dcb(adb)end end end
local function _cb(bcb,ccb,dcb)if ccb==0 then dcb(bcb)end
for i=1,ccb do bcb[ccb],bcb[i]=bcb[i],bcb[ccb]_cb(bcb,ccb-
1,dcb)bcb[ccb],bcb[i]=bcb[i],bcb[ccb]end end;local acb=-1
function _ab.each(bcb,ccb,...)for dcb,_db in c_b(bcb)do ccb(dcb,_db,...)end end
function _ab.eachi(bcb,ccb,...)
local dcb=_ab.sort(_ab.select(_ab.keys(bcb),function(_db,adb)return _ab.isInteger(adb)end))for _db,adb in d_b(dcb)do ccb(adb,bcb[adb],...)end end
function _ab.at(bcb,...)local ccb={}for dcb,_db in d_b({...})do
if _ab.has(bcb,_db)then ccb[#ccb+1]=bcb[_db]end end;return ccb end
function _ab.count(bcb,ccb)if _ab.isNil(ccb)then return _ab.size(bcb)end;local dcb=0
_ab.each(bcb,function(_db,adb)if
_ab.isEqual(adb,ccb)then dcb=dcb+1 end end)return dcb end
function _ab.countf(bcb,ccb,...)return _ab.count(_ab.map(bcb,ccb,...),true)end
function _ab.cycle(bcb,ccb)ccb=ccb or 1;if ccb<=0 then return _ab.noop end;local dcb,_db;local adb=0
while true do
return
function()dcb=dcb and
_ba(bcb,dcb)or _ba(bcb)
_db=not _db and dcb or _db;if ccb then adb=(dcb==_db)and adb+1 or adb
if adb>ccb then return end end;return dcb,bcb[dcb]end end end
function _ab.map(bcb,ccb,...)local dcb={}
for _db,adb in c_b(bcb)do local bdb,cdb,ddb=_db,ccb(_db,adb,...)dcb[ddb and cdb or bdb]=
ddb or cdb end;return dcb end;function _ab.reduce(bcb,ccb,dcb)
for _db,adb in c_b(bcb)do if dcb==nil then dcb=adb else dcb=ccb(dcb,adb)end end;return dcb end;function _ab.reduceby(bcb,ccb,dcb,_db,...)return
_ab.reduce(_ab.select(bcb,_db,...),ccb,dcb)end;function _ab.reduceRight(bcb,ccb,dcb)return
_ab.reduce(_ab.reverse(bcb),ccb,dcb)end
function _ab.mapReduce(bcb,ccb,dcb)
local _db={}for adb,bdb in c_b(bcb)do _db[adb]=not dcb and bdb or ccb(dcb,bdb)
dcb=_db[adb]end;return _db end;function _ab.mapReduceRight(bcb,ccb,dcb)
return _ab.mapReduce(_ab.reverse(bcb),ccb,dcb)end
function _ab.include(bcb,ccb)local dcb=
_ab.isFunction(ccb)and ccb or _ab.isEqual;for _db,adb in c_b(bcb)do if dcb(adb,ccb)then
return true end end;return false end
function _ab.detect(bcb,ccb)
local dcb=_ab.isFunction(ccb)and ccb or _ab.isEqual;for _db,adb in c_b(bcb)do if dcb(adb,ccb)then return _db end end end
function _ab.where(bcb,ccb)
local dcb=_ab.select(bcb,function(_db,adb)
for bdb in c_b(ccb)do if adb[bdb]~=ccb[bdb]then return false end end;return true end)return#dcb>0 and dcb or nil end
function _ab.findWhere(bcb,ccb)
local dcb=_ab.detect(bcb,function(_db)for adb in c_b(ccb)do
if ccb[adb]~=_db[adb]then return false end end;return true end)return dcb and bcb[dcb]end
function _ab.select(bcb,ccb,...)local dcb={}for _db,adb in c_b(bcb)do
if ccb(_db,adb,...)then dcb[#dcb+1]=adb end end;return dcb end
function _ab.reject(bcb,ccb,...)local dcb=_ab.map(bcb,ccb,...)local _db={}for adb,bdb in c_b(dcb)do if not bdb then
_db[#_db+1]=bcb[adb]end end;return _db end
function _ab.all(bcb,ccb,...)return( (#_ab.select(_ab.map(bcb,ccb,...),dab))==
abb(bcb))end
function _ab.invoke(bcb,ccb,...)local dcb={...}
return
_ab.map(bcb,function(_db,adb)
if _ab.isTable(adb)then
if _ab.has(adb,ccb)then
if
_ab.isCallable(adb[ccb])then return adb[ccb](adb,b_b(dcb))else return adb[ccb]end else
if _ab.isCallable(ccb)then return ccb(adb,b_b(dcb))end end elseif _ab.isCallable(ccb)then return ccb(adb,b_b(dcb))end end)end
function _ab.pluck(bcb,ccb)return
_ab.reject(_ab.map(bcb,function(dcb,_db)return _db[ccb]end),_bb)end;function _ab.max(bcb,ccb,...)return bbb(bcb,aab,ccb,...)end;function _ab.min(bcb,ccb,...)return
bbb(bcb,bab,ccb,...)end
function _ab.shuffle(bcb,ccb)if ccb then _da(ccb)end
local dcb={}
_ab.each(bcb,function(_db,adb)local bdb=cda(ada()*_db)+1;dcb[_db]=dcb[bdb]
dcb[bdb]=adb end)return dcb end
function _ab.same(bcb,ccb)
return
_ab.all(bcb,function(dcb,_db)return _ab.include(ccb,_db)end)and
_ab.all(ccb,function(dcb,_db)return _ab.include(bcb,_db)end)end;function _ab.sort(bcb,ccb)bca(bcb,ccb)return bcb end
function _ab.sortBy(bcb,ccb,dcb)
local _db=ccb or _ab.identity
if _ab.isString(ccb)then _db=function(bdb)return bdb[ccb]end end;dcb=dcb or bab;local adb={}
_ab.each(bcb,function(bdb,cdb)
adb[#adb+1]={value=cdb,transform=_db(cdb)}end)
bca(adb,function(bdb,cdb)return dcb(bdb.transform,cdb.transform)end)return _ab.pluck(adb,'value')end
function _ab.groupBy(bcb,ccb,...)local dcb={...}local _db={}
_ab.each(bcb,function(adb,bdb)local cdb=ccb(adb,bdb,b_b(dcb))
if
_db[cdb]then _db[cdb][#_db[cdb]+1]=bdb else _db[cdb]={bdb}end end)return _db end
function _ab.countBy(bcb,ccb,...)local dcb={...}local _db={}
_ab.each(bcb,function(adb,bdb)local cdb=ccb(adb,bdb,b_b(dcb))_db[cdb]=(
_db[cdb]or 0)+1 end)return _db end
function _ab.size(...)local bcb={...}local ccb=bcb[1]if _ab.isTable(ccb)then return abb(bcb[1])else
return abb(bcb)end end;function _ab.containsKeys(bcb,ccb)
for dcb in c_b(ccb)do if not bcb[dcb]then return false end end;return true end
function _ab.sameKeys(bcb,ccb)for dcb in
c_b(bcb)do if not ccb[dcb]then return false end end;for dcb in
c_b(ccb)do if not bcb[dcb]then return false end end
return true end
function _ab.sample(bcb,ccb,dcb)ccb=ccb or 1;if ccb<1 then return end;if ccb==1 then if dcb then _da(dcb)end;return
bcb[ada(1,#bcb)]end;return
_ab.slice(_ab.shuffle(bcb,dcb),1,ccb)end
function _ab.sampleProb(bcb,ccb,dcb)if dcb then _da(dcb)end;return
_ab.select(bcb,function(_db,adb)return ada()<ccb end)end;function _ab.toArray(...)return{...}end
function _ab.find(bcb,ccb,dcb)for i=dcb or 1,#bcb do if
_ab.isEqual(bcb[i],ccb)then return i end end end
function _ab.reverse(bcb)local ccb={}for i=#bcb,1,-1 do ccb[#ccb+1]=bcb[i]end;return ccb end;function _ab.fill(bcb,ccb,dcb,_db)_db=_db or _ab.size(bcb)
for i=dcb or 1,_db do bcb[i]=ccb end;return bcb end
function _ab.selectWhile(bcb,ccb,...)
local dcb={}
for _db,adb in d_b(bcb)do if ccb(_db,adb,...)then dcb[_db]=adb else break end end;return dcb end
function _ab.dropWhile(bcb,ccb,...)local dcb
for _db,adb in d_b(bcb)do if not ccb(_db,adb,...)then dcb=_db;break end end;if _ab.isNil(dcb)then return{}end;return _ab.rest(bcb,dcb)end
function _ab.sortedIndex(bcb,ccb,dcb,_db)local adb=dcb or bab;if _db then _ab.sort(bcb,adb)end;for i=1,#bcb do if not
adb(bcb[i],ccb)then return i end end
return#bcb+1 end
function _ab.indexOf(bcb,ccb)for k=1,#bcb do if bcb[k]==ccb then return k end end end
function _ab.lastIndexOf(bcb,ccb)local dcb=_ab.indexOf(_ab.reverse(bcb),ccb)if dcb then return
#bcb-dcb+1 end end;function _ab.findIndex(bcb,ccb,...)
for k=1,#bcb do if ccb(k,bcb[k],...)then return k end end end
function _ab.findLastIndex(bcb,ccb,...)
local dcb=_ab.findIndex(_ab.reverse(bcb),ccb,...)if dcb then return#bcb-dcb+1 end end;function _ab.addTop(bcb,...)
_ab.each({...},function(ccb,dcb)aca(bcb,1,dcb)end)return bcb end;function _ab.push(bcb,...)_ab.each({...},function(ccb,dcb)
bcb[#bcb+1]=dcb end)
return bcb end
function _ab.pop(bcb,ccb)
ccb=__b(ccb or 1,#bcb)local dcb={}
for i=1,ccb do local _db=bcb[1]dcb[#dcb+1]=_db;cca(bcb,1)end;return b_b(dcb)end
function _ab.unshift(bcb,ccb)ccb=__b(ccb or 1,#bcb)local dcb={}for i=1,ccb do local _db=bcb[#bcb]
dcb[#dcb+1]=_db;cca(bcb)end;return b_b(dcb)end
function _ab.pull(bcb,...)
for ccb,dcb in d_b({...})do for i=#bcb,1,-1 do
if _ab.isEqual(bcb[i],dcb)then cca(bcb,i)end end end;return bcb end
function _ab.removeRange(bcb,ccb,dcb)local _db=_ab.clone(bcb)local adb,bdb=(_ba(_db)),#_db
if bdb<1 then return _db end;ccb=cab(ccb or adb,adb,bdb)
dcb=cab(dcb or bdb,adb,bdb)if dcb<ccb then return _db end;local cdb=dcb-ccb+1;local ddb=ccb;while cdb>0 do
cca(_db,ddb)cdb=cdb-1 end;return _db end
function _ab.chunk(bcb,ccb,...)if not _ab.isArray(bcb)then return bcb end;local dcb,_db,adb={},0
local bdb=_ab.map(bcb,ccb,...)
_ab.each(bdb,function(cdb,ddb)adb=(adb==nil)and ddb or adb;_db=(
(ddb~=adb)and(_db+1)or _db)
if not dcb[_db]then dcb[_db]={bcb[cdb]}else dcb[_db][
#dcb[_db]+1]=bcb[cdb]end;adb=ddb end)return dcb end
function _ab.slice(bcb,ccb,dcb)return
_ab.select(bcb,function(_db)return
(_db>= (ccb or _ba(bcb))and _db<= (dcb or#bcb))end)end;function _ab.first(bcb,ccb)local dcb=ccb or 1
return _ab.slice(bcb,1,__b(dcb,#bcb))end
function _ab.initial(bcb,ccb)
if ccb and ccb<0 then return end;return
_ab.slice(bcb,1,ccb and#bcb- (__b(ccb,#bcb))or#bcb-1)end;function _ab.last(bcb,ccb)if ccb and ccb<=0 then return end
return _ab.slice(bcb,ccb and
#bcb-__b(ccb-1,#bcb-1)or 2,#bcb)end;function _ab.rest(bcb,ccb)if ccb and
ccb>#bcb then return{}end
return _ab.slice(bcb,
ccb and dda(1,__b(ccb,#bcb))or 1,#bcb)end;function _ab.nth(bcb,ccb)
return bcb[ccb]end;function _ab.compact(bcb)return
_ab.reject(bcb,function(ccb,dcb)return not dcb end)end
function _ab.flatten(bcb,ccb)local dcb=
ccb or false;local _db;local adb={}
for bdb,cdb in c_b(bcb)do
if _ab.isTable(cdb)then _db=dcb and cdb or
_ab.flatten(cdb)
_ab.each(_db,function(ddb,__c)adb[#adb+1]=__c end)else adb[#adb+1]=cdb end end;return adb end
function _ab.difference(bcb,ccb)if not ccb then return _ab.clone(bcb)end;return
_ab.select(bcb,function(dcb,_db)return not
_ab.include(ccb,_db)end)end
function _ab.union(...)return _ab.uniq(_ab.flatten({...}))end
function _ab.intersection(bcb,...)local ccb={...}local dcb={}
for _db,adb in d_b(bcb)do if
_ab.all(ccb,function(bdb,cdb)return _ab.include(cdb,adb)end)then aca(dcb,adb)end end;return dcb end
function _ab.symmetricDifference(bcb,ccb)return
_ab.difference(_ab.union(bcb,ccb),_ab.intersection(bcb,ccb))end
function _ab.unique(bcb)local ccb={}for i=1,#bcb do if not _ab.find(ccb,bcb[i])then
ccb[#ccb+1]=bcb[i]end end;return ccb end
function _ab.isunique(bcb)return _ab.isEqual(bcb,_ab.unique(bcb))end
function _ab.zip(...)local bcb={...}
local ccb=_ab.max(_ab.map(bcb,function(_db,adb)return#adb end))local dcb={}for i=1,ccb do dcb[i]=_ab.pluck(bcb,i)end;return dcb end
function _ab.append(bcb,ccb)local dcb={}for _db,adb in d_b(bcb)do dcb[_db]=adb end;for _db,adb in d_b(ccb)do
dcb[#dcb+1]=adb end;return dcb end
function _ab.interleave(...)return _ab.flatten(_ab.zip(...))end;function _ab.interpose(bcb,ccb)return
_ab.flatten(_ab.zip(ccb,_ab.rep(bcb,#ccb-1)))end
function _ab.range(...)
local bcb={...}local ccb,dcb,_db
if#bcb==0 then return{}elseif#bcb==1 then dcb,ccb,_db=bcb[1],0,1 elseif#bcb==2 then
ccb,dcb,_db=bcb[1],bcb[2],1 elseif#bcb==3 then ccb,dcb,_db=bcb[1],bcb[2],bcb[3]end;if(_db and _db==0)then return{}end;local adb={}
local bdb=dda(cda((dcb-ccb)/_db),0)for i=1,bdb do adb[#adb+1]=ccb+_db*i end;if#adb>0 then
aca(adb,1,ccb)end;return adb end
function _ab.rep(bcb,ccb)local dcb={}for i=1,ccb do dcb[#dcb+1]=bcb end;return dcb end;function _ab.partition(bcb,ccb,dcb)if ccb<=0 then return end
return coroutine.wrap(function()
cbb(bcb,ccb or 1,coroutine.yield,dcb)end)end;function _ab.sliding(bcb,ccb,dcb)if
ccb<=1 then return end
return coroutine.wrap(function()
dbb(bcb,ccb or 2,coroutine.yield,dcb)end)end
function _ab.permutation(bcb)return
coroutine.wrap(function()_cb(bcb,
#bcb,coroutine.yield)end)end;function _ab.invert(bcb)local ccb={}
_ab.each(bcb,function(dcb,_db)ccb[_db]=dcb end)return ccb end
function _ab.concat(bcb,ccb,dcb,_db)
local adb=_ab.map(bcb,function(bdb,cdb)return
tostring(cdb)end)return dca(adb,ccb,dcb or 1,_db or#bcb)end;function _ab.noop()return end;function _ab.identity(bcb)return bcb end;function _ab.constant(bcb)return
function()return bcb end end
function _ab.once(bcb)local ccb=0;local dcb={}return
function(...)ccb=ccb+1;if
ccb<=1 then dcb={...}end;return bcb(b_b(dcb))end end
function _ab.memoize(bcb,ccb)local dcb=dba({},{__mode='kv'})
local _db=ccb or _ab.identity
return function(...)local adb=_db(...)local bdb=dcb[adb]
if not bdb then dcb[adb]=bcb(...)end;return dcb[adb]end end
function _ab.after(bcb,ccb)local dcb,_db=ccb,0;return
function(...)_db=_db+1;if _db>=dcb then return bcb(...)end end end
function _ab.compose(...)local bcb=_ab.reverse{...}
return function(...)local ccb,dcb=true
for _db,adb in d_b(bcb)do if ccb then ccb=false
dcb=adb(...)else dcb=adb(dcb)end end;return dcb end end
function _ab.pipe(bcb,...)return _ab.compose(...)(bcb)end
function _ab.complement(bcb)return function(...)return not bcb(...)end end;function _ab.juxtapose(bcb,...)local ccb={}
_ab.each({...},function(dcb,_db)ccb[#ccb+1]=_db(bcb)end)return b_b(ccb)end
function _ab.wrap(bcb,ccb)return function(...)return
ccb(bcb,...)end end
function _ab.times(bcb,ccb,...)local dcb={}for i=1,bcb do dcb[i]=ccb(i,...)end;return dcb end
function _ab.bind(bcb,ccb)return function(...)return bcb(ccb,...)end end;function _ab.bind2(bcb,ccb)
return function(dcb,...)return bcb(dcb,ccb,...)end end;function _ab.bindn(bcb,...)local ccb={...}
return function(...)return
bcb(b_b(_ab.append(ccb,{...})))end end
function _ab.bindAll(bcb,...)local ccb={...}
for dcb,_db in
d_b(ccb)do local adb=bcb[_db]if adb then bcb[_db]=_ab.bind(adb,bcb)end end;return bcb end
function _ab.uniqueId(bcb,...)acb=acb+1
if bcb then if _ab.isString(bcb)then return bcb:format(acb)elseif
_ab.isFunction(bcb)then return bcb(acb,...)end end;return acb end
function _ab.iterator(bcb,ccb)return function()ccb=bcb(ccb)return ccb end end;function _ab.flip(bcb)return
function(...)return bcb(b_b(_ab.reverse({...})))end end;function _ab.over(...)
local bcb={...}
return function(...)local ccb={}for dcb,_db in d_b(bcb)do ccb[#ccb+1]=_db(...)end
return ccb end end;function _ab.overEvery(...)
local bcb=_ab.over(...)
return function(...)return
_ab.reduce(bcb(...),function(ccb,dcb)return ccb and dcb end)end end;function _ab.overSome(...)
local bcb=_ab.over(...)
return function(...)return
_ab.reduce(bcb(...),function(ccb,dcb)return ccb or dcb end)end end
function _ab.overArgs(bcb,...)
local ccb={...}return
function(...)local dcb={...}for i=1,#ccb do local _db=ccb[i]
if dcb[i]then dcb[i]=_db(dcb[i])end end;return bcb(b_b(dcb))end end
function _ab.partial(bcb,...)local ccb={...}
return
function(...)local dcb={...}local _db={}for adb,bdb in d_b(ccb)do _db[adb]=
(bdb=='_')and _ab.pop(dcb)or bdb end;return
bcb(b_b(_ab.append(_db,dcb)))end end
function _ab.partialRight(bcb,...)local ccb={...}
return
function(...)local dcb={...}local _db={}
for k=1,#ccb do _db[k]=
(ccb[k]=='_')and _ab.pop(dcb)or ccb[k]end;return bcb(b_b(_ab.append(dcb,_db)))end end
function _ab.curry(bcb,ccb)ccb=ccb or 2;local dcb={}
local function _db(adb)if ccb==1 then return bcb(adb)end;if adb~=nil then
dcb[#dcb+1]=adb end;if#dcb<ccb then return _db else local bdb={bcb(b_b(dcb))}dcb={}return
b_b(bdb)end end;return _db end;function _ab.keys(bcb)local ccb={}
_ab.each(bcb,function(dcb)ccb[#ccb+1]=dcb end)return ccb end;function _ab.values(bcb)local ccb={}
_ab.each(bcb,function(dcb,_db)ccb[
#ccb+1]=_db end)return ccb end;function _ab.kvpairs(bcb)local ccb={}
_ab.each(bcb,function(dcb,_db)ccb[
#ccb+1]={dcb,_db}end)return ccb end
function _ab.toObj(bcb)local ccb={}for dcb,_db in
d_b(bcb)do ccb[_db[1]]=_db[2]end;return ccb end
function _ab.property(bcb)return function(ccb)return ccb[bcb]end end
function _ab.propertyOf(bcb)return function(ccb)return bcb[ccb]end end;function _ab.toBoolean(bcb)return not not bcb end
function _ab.extend(bcb,...)local ccb={...}
_ab.each(ccb,function(dcb,_db)if
_ab.isTable(_db)then
_ab.each(_db,function(adb,bdb)bcb[adb]=bdb end)end end)return bcb end
function _ab.functions(bcb,ccb)bcb=bcb or _ab;local dcb={}
_ab.each(bcb,function(adb,bdb)if _ab.isFunction(bdb)then
dcb[#dcb+1]=adb end end)if not ccb then return _ab.sort(dcb)end;local _db=_ca(bcb)
if
_db and _db.__index then local adb=_ab.functions(_db.__index)_ab.each(adb,function(bdb,cdb)
dcb[#dcb+1]=cdb end)end;return _ab.sort(dcb)end
function _ab.clone(bcb,ccb)if not _ab.isTable(bcb)then return bcb end;local dcb={}
_ab.each(bcb,function(_db,adb)if
_ab.isTable(adb)then
if not ccb then dcb[_db]=_ab.clone(adb,ccb)else dcb[_db]=adb end else dcb[_db]=adb end end)return dcb end;function _ab.tap(bcb,ccb,...)ccb(bcb,...)return bcb end;function _ab.has(bcb,ccb)return
bcb[ccb]~=nil end
function _ab.pick(bcb,...)local ccb=_ab.flatten{...}
local dcb={}
_ab.each(ccb,function(_db,adb)
if not _ab.isNil(bcb[adb])then dcb[adb]=bcb[adb]end end)return dcb end
function _ab.omit(bcb,...)local ccb=_ab.flatten{...}local dcb={}
_ab.each(bcb,function(_db,adb)if
not _ab.include(ccb,_db)then dcb[_db]=adb end end)return dcb end;function _ab.template(bcb,ccb)
_ab.each(ccb or{},function(dcb,_db)if not bcb[dcb]then bcb[dcb]=_db end end)return bcb end
function _ab.isEqual(bcb,ccb,dcb)
local _db=aba(bcb)local adb=aba(ccb)if _db~=adb then return false end
if _db~='table'then return(bcb==ccb)end;local bdb=_ca(bcb)local cdb=_ca(ccb)if dcb then
if
(bdb or cdb)and(bdb.__eq or cdb.__eq)then return
bdb.__eq(bcb,ccb)or cdb.__eq(ccb,bcb)or(bcb==ccb)end end;if _ab.size(bcb)~=
_ab.size(ccb)then return false end;for ddb,__c in c_b(bcb)do local a_c=ccb[ddb]
if
_ab.isNil(a_c)or not _ab.isEqual(__c,a_c,dcb)then return false end end
for ddb,__c in c_b(ccb)do
local a_c=bcb[ddb]if _ab.isNil(a_c)then return false end end;return true end
function _ab.result(bcb,ccb,...)
if bcb[ccb]then if _ab.isCallable(bcb[ccb])then return bcb[ccb](bcb,...)else return
bcb[ccb]end end;if _ab.isCallable(ccb)then return ccb(bcb,...)end end;function _ab.isTable(bcb)return aba(bcb)=='table'end
function _ab.isCallable(bcb)return
(
_ab.isFunction(bcb)or
(_ab.isTable(bcb)and _ca(bcb)and _ca(bcb).__call~=nil)or false)end
function _ab.isArray(bcb)if not _ab.isTable(bcb)then return false end;local ccb=0
for dcb in
c_b(bcb)do ccb=ccb+1;if _ab.isNil(bcb[ccb])then return false end end;return true end
function _ab.isIterable(bcb)return _ab.toBoolean((cba(c_b,bcb)))end
function _ab.isEmpty(bcb)if _ab.isNil(bcb)then return true end;if _ab.isString(bcb)then
return#bcb==0 end
if _ab.isTable(bcb)then return _ba(bcb)==nil end;return true end;function _ab.isString(bcb)return aba(bcb)=='string'end;function _ab.isFunction(bcb)return
aba(bcb)=='function'end;function _ab.isNil(bcb)
return bcb==nil end
function _ab.isNumber(bcb)return aba(bcb)=='number'end
function _ab.isNaN(bcb)return _ab.isNumber(bcb)and bcb~=bcb end
function _ab.isFinite(bcb)if not _ab.isNumber(bcb)then return false end;return
bcb>-bda and bcb<bda end;function _ab.isBoolean(bcb)return aba(bcb)=='boolean'end
function _ab.isInteger(bcb)return
_ab.isNumber(bcb)and cda(bcb)==bcb end
do _ab.forEach=_ab.each;_ab.forEachi=_ab.eachi;_ab.loop=_ab.cycle
_ab.collect=_ab.map;_ab.inject=_ab.reduce;_ab.foldl=_ab.reduce
_ab.injectr=_ab.reduceRight;_ab.foldr=_ab.reduceRight;_ab.mapr=_ab.mapReduce
_ab.maprr=_ab.mapReduceRight;_ab.any=_ab.include;_ab.some=_ab.include;_ab.contains=_ab.include
_ab.filter=_ab.select;_ab.discard=_ab.reject;_ab.every=_ab.all
_ab.takeWhile=_ab.selectWhile;_ab.rejectWhile=_ab.dropWhile;_ab.shift=_ab.pop;_ab.remove=_ab.pull
_ab.rmRange=_ab.removeRange;_ab.chop=_ab.removeRange;_ab.sub=_ab.slice;_ab.head=_ab.first
_ab.take=_ab.first;_ab.tail=_ab.rest;_ab.skip=_ab.last;_ab.without=_ab.difference
_ab.diff=_ab.difference;_ab.symdiff=_ab.symmetricDifference;_ab.xor=_ab.symmetricDifference
_ab.uniq=_ab.unique;_ab.isuniq=_ab.isunique;_ab.transpose=_ab.zip;_ab.part=_ab.partition
_ab.perm=_ab.permutation;_ab.mirror=_ab.invert;_ab.join=_ab.concat;_ab.cache=_ab.memoize
_ab.juxt=_ab.juxtapose;_ab.uid=_ab.uniqueId;_ab.iter=_ab.iterator;_ab.methods=_ab.functions
_ab.choose=_ab.pick;_ab.drop=_ab.omit;_ab.defaults=_ab.template;_ab.compare=_ab.isEqual end
do local bcb={}local ccb={}ccb.__index=bcb;local function dcb(_db)local adb={_value=_db,_wrapped=true}
return dba(adb,ccb)end
dba(ccb,{__call=function(_db,adb)return dcb(adb)end,__index=function(_db,adb,...)return
bcb[adb]end})function ccb.chain(_db)return dcb(_db)end
function ccb:value()return self._value end;bcb.chain,bcb.value=ccb.chain,ccb.value
for _db,adb in c_b(_ab)do
bcb[_db]=function(bdb,...)local cdb=_ab.isTable(bdb)and
bdb._wrapped or false
if cdb then
local ddb=bdb._value;local __c=adb(ddb,...)return dcb(__c)else return adb(bdb,...)end end end
bcb.import=function(_db,adb)_db=_db or _ENV or _G;local bdb=_ab.functions()
_ab.each(bdb,function(cdb,ddb)
if
a_b(_db,ddb)then if not adb then _db[ddb]=_ab[ddb]end else _db[ddb]=_ab[ddb]end end)return _db end;ccb._VERSION='Moses v'..daa
ccb._URL='http://github.com/Yonaba/Moses'
ccb._LICENSE='MIT <http://raw.githubusercontent.com/Yonaba/Moses/master/LICENSE>'ccb._DESCRIPTION='utility-belt library for functional programming in Lua'return
ccb end