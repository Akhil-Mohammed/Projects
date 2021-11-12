package com.cs336.pkg;

import java.util.*;
import java.util.Map.Entry;

public class Generic {
	public static <K, V extends Comparable<V>> Map<K, V> getSortedMap(Map<K, V> map, final boolean descending) {
        List<Entry<K, V>> list = new LinkedList<Entry<K, V>>(map.entrySet());

        Collections.sort(list, new Comparator<Entry<K, V>>() {
            public int compare(Entry<K, V> o1, Entry<K, V> o2) {
            	return descending ? 
            			o2.getValue().compareTo(o1.getValue()) :
            			o1.getValue().compareTo(o2.getValue());
            }
        });

        Map<K, V> sortedMap = new LinkedHashMap<K, V>();
        for (Entry<K, V> entry : list) {
            sortedMap.put(entry.getKey(), entry.getValue());
        }

        return sortedMap;
    }
}
