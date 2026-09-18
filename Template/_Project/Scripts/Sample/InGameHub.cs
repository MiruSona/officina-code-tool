// 본보기다. 자기 Master 를 만들고 이 폴더를 지운다.
using Officina.Hubs;
using UnityEngine;

namespace Officina.Sample
{
    public static class InGameHub
    {
        private static readonly HubTable _table = new HubTable("InGameHub");

        // Domain Reload 를 꺼도 플레이마다 표를 비운다.
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        private static void ResetStatics()
        {
            _table.Clear();
        }

        public static T Get<T>() where T : class
        {
            return _table.Get<T>();
        }

        public static bool TryGet<T>(out T hub) where T : class
        {
            return _table.TryGet<T>(out hub);
        }

        public static void Register<T>(T hub, object owner) where T : class
        {
            _table.Register<T>(hub, owner);
        }

        public static void UnregisterAllBy(object owner)
        {
            _table.UnregisterAllBy(owner);
        }

        public static void Clear()
        {
            _table.Clear();
        }
    }
}
